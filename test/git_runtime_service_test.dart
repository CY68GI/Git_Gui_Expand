import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_installation_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_service.dart';

void main() {
  late Directory temporaryDirectory;
  late AppStorageService storage;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'git_gui_runtime_',
    );
    storage = AppStorageService(
      softwareDirectoryOverride: temporaryDirectory.path,
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('reports unavailable when no system or bundled Git validates', () async {
    final discovery = GitRuntimeDiscovery(
      storage: storage,
      candidateProvider: () async => const [],
      versionProbe: (_) async => null,
    );

    final status = await discovery.discover();

    expect(status.isAvailable, isFalse);
    expect(status.source, isNull);
    expect(status.checkedAt, isNotNull);
    expect(status.error, contains('No Git executable'));
  });

  test('uses a valid system Git when no bundled runtime exists', () async {
    const systemPath = r'C:\Program Files\Git\cmd\git.exe';
    final discovery = GitRuntimeDiscovery(
      storage: storage,
      candidateProvider: () async => const [systemPath],
      versionProbe: (path) async =>
          path == systemPath ? '2.56.1.windows.1' : null,
    );

    final status = await discovery.discover();

    expect(status.isAvailable, isTrue);
    expect(status.source, GitRuntimeSource.system);
    expect(status.executablePath, systemPath);
    expect(status.version, '2.56.1.windows.1');
  });

  test('uses bundled Git when no external system Git validates', () async {
    final bundled = storage.gitRuntimeExecutableFile.path;
    final discovery = GitRuntimeDiscovery(
      storage: storage,
      candidateProvider: () async => const [],
      versionProbe: (path) async => path == bundled ? '2.50.0' : null,
    );

    final status = await discovery.discover();

    expect(status.isAvailable, isTrue);
    expect(status.source, GitRuntimeSource.bundled);
    expect(status.executablePath, bundled);
    expect(status.version, '2.50.0');
  });

  test('system Git wins when both sources are available', () async {
    const systemPath = r'C:\Program Files\Git\cmd\git.exe';
    final bundled = storage.gitRuntimeExecutableFile.path;
    final discovery = GitRuntimeDiscovery(
      storage: storage,
      candidateProvider: () async => const [systemPath],
      versionProbe: (path) async =>
          path == systemPath || path == bundled ? '2.56.1' : null,
    );

    final status = await discovery.discover();

    expect(status.source, GitRuntimeSource.system);
    expect(status.executablePath, systemPath);
  });

  test('a bundled path in PATH remains classified as bundled', () async {
    final bundled = storage.gitRuntimeExecutableFile.path;
    final discovery = GitRuntimeDiscovery(
      storage: storage,
      candidateProvider: () async => [bundled],
      versionProbe: (path) async => path == bundled ? '2.50.0' : null,
    );

    final status = await discovery.discover();

    expect(status.isAvailable, isTrue);
    expect(status.source, GitRuntimeSource.bundled);
    expect(status.executablePath, bundled);
  });

  test('runtime activation waits for active Git commands', () async {
    final manager = GitRuntimeManager(
      discovery: GitRuntimeDiscovery(
        storage: storage,
        candidateProvider: () async => const [],
        versionProbe: (_) async => null,
      ),
    );
    final installation = _RecordingInstallationService(storage: storage);
    final gate = Completer<void>();
    unawaited(
      manager.runWithCommandTracking(() async {
        await gate.future;
      }),
    );
    final runtime = _fakeValidatedRuntime(storage);
    var completed = false;

    final activation = manager
        .activateRuntime(
          installationService: installation,
          runtime: runtime,
          idleTimeout: const Duration(seconds: 1),
        )
        .then((_) => completed = true);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(installation.activateCalls, 0);
    expect(completed, isFalse);

    gate.complete();
    await activation;
    expect(installation.activateCalls, 1);
    expect(completed, isTrue);
  });

  test(
    'runtime activation refuses to replace a busy runtime on timeout',
    () async {
      final manager = GitRuntimeManager(
        discovery: GitRuntimeDiscovery(
          storage: storage,
          candidateProvider: () async => const [],
          versionProbe: (_) async => null,
        ),
      );
      final installation = _RecordingInstallationService(storage: storage);
      final gate = Completer<void>();
      unawaited(
        manager.runWithCommandTracking(() async {
          await gate.future;
        }),
      );

      await expectLater(
        manager.activateRuntime(
          installationService: installation,
          runtime: _fakeValidatedRuntime(storage),
          idleTimeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(installation.activateCalls, 0);
      gate.complete();
    },
  );
}

ValidatedGitRuntime _fakeValidatedRuntime(AppStorageService storage) {
  final directory = storage.gitRuntimeVersionDirectory(
    'PortableGit-test-64-bit',
  );
  final executable = File(
    '${directory.path}${Platform.pathSeparator}cmd'
    '${Platform.pathSeparator}git.exe',
  );
  final manifest = GitRuntimeManifest(
    runtimeFormat: 1,
    packageName: 'PortableGit-test-64-bit',
    gitVersion: '2.56.1.windows.1',
    sourceUrl: 'https://example.com/PortableGit.7z.exe',
    archiveSha256: List.filled(64, 'a').join(),
    licensePath: 'licenses/GIT-COPYING.txt',
    noticePath: 'licenses/PORTABLEGIT-NOTICE.txt',
    builtAt: '2026-11-23T00:00:00Z',
  );
  return ValidatedGitRuntime(
    directory: directory,
    executable: executable,
    manifest: manifest,
    smokeResult: GitRuntimeSmokeResult(
      version: manifest.gitVersion,
      execPath: '${directory.path}${Platform.pathSeparator}mingw64',
    ),
  );
}

class _RecordingInstallationService extends GitRuntimeInstallationService {
  _RecordingInstallationService({required super.storage});

  int activateCalls = 0;

  @override
  Future<ValidatedGitRuntime> activate(
    ValidatedGitRuntime runtime, {
    Future<void> Function()? waitUntilIdle,
  }) async {
    activateCalls++;
    return runtime;
  }
}
