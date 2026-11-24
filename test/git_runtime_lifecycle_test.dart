import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_installation_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_service.dart';
import 'package:git_gui_expand/core/services/installation_maintenance_service.dart';

void main() {
  late Directory root;
  late AppStorageService storage;
  late AppLogService logger;
  late GitRuntimePointerStore pointerStore;
  late GitRuntimeInstallationService installation;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('git_runtime_lifecycle_');
    storage = AppStorageService(softwareDirectoryOverride: root.path);
    logger = AppLogService(storage: storage);
    pointerStore = GitRuntimePointerStore(storage: storage);
    installation = GitRuntimeInstallationService(
      storage: storage,
      pointerStore: pointerStore,
      smokeProbe: _fakeSmoke,
      stableLinkUpdater: (_, _) async {},
    );
  });

  tearDown(() async {
    await logger.flush();
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'clean machine reports missing Git until a PortableGit runtime is active',
    () async {
      final emptyMachine = GitRuntimeDiscovery(
        storage: storage,
        pointerStore: pointerStore,
        installationService: installation,
        candidateProvider: () async => const [],
        versionProbe: (_) async => null,
      );
      expect((await emptyMachine.discover()).isAvailable, isFalse);

      final runtime = await _createRuntime(
        storage,
        'PortableGit-2.56.1-64-bit',
        '2.56.1.windows.1',
      );
      final validated = await installation.validate(runtime);
      await installation.activate(validated);

      final portableMachine = GitRuntimeDiscovery(
        storage: storage,
        pointerStore: pointerStore,
        installationService: installation,
        candidateProvider: () async => const [],
        versionProbe: (_) async => null,
      );
      final status = await portableMachine.discover();
      expect(status.isAvailable, isTrue);
      expect(status.source, GitRuntimeSource.bundled);
      expect(status.version, '2.56.1.windows.1');
      expect(status.executablePath, contains('PortableGit-2.56.1-64-bit'));
    },
  );

  test(
    'system Git wins even when the bundled path is listed in PATH first',
    () async {
      final bundled = await _createRuntime(
        storage,
        'PortableGit-2.56.1-64-bit',
        '2.56.1.windows.1',
      );
      await installation.activate(await installation.validate(bundled));
      const systemPath = r'C:\Program Files\Git\cmd\git.exe';
      final discovery = GitRuntimeDiscovery(
        storage: storage,
        pointerStore: pointerStore,
        installationService: installation,
        candidateProvider: () async => [
          storage.gitRuntimeExecutableFile.path,
          systemPath,
        ],
        versionProbe: (path) async =>
            path == systemPath ? '2.56.1.windows.1' : null,
      );

      final status = await discovery.discover();

      expect(status.source, GitRuntimeSource.system);
      expect(status.executablePath, systemPath);
    },
  );

  test(
    'restart re-detects the active runtime and rolls back a corrupt update',
    () async {
      final previous = await _createRuntime(
        storage,
        'PortableGit-2.56.1-64-bit',
        '2.56.1.windows.1',
      );
      final active = await _createRuntime(
        storage,
        'PortableGit-2.57.0-64-bit',
        '2.57.0.windows.1',
      );
      await installation.activate(await installation.validate(previous));
      await installation.activate(await installation.validate(active));

      final afterRestart = GitRuntimeDiscovery(
        storage: storage,
        pointerStore: pointerStore,
        installationService: installation,
        candidateProvider: () async => const [],
        versionProbe: (_) async => null,
      );
      expect((await afterRestart.discover()).version, '2.57.0.windows.1');

      await File('${active.path}${Platform.pathSeparator}git-runtime.json')
          .delete();
      final afterCorruption = GitRuntimeDiscovery(
        storage: storage,
        pointerStore: pointerStore,
        installationService: installation,
        candidateProvider: () async => const [],
        versionProbe: (_) async => null,
      );
      final recovered = await afterCorruption.discover();
      final pointer = await pointerStore.read();

      expect(recovered.isAvailable, isTrue);
      expect(recovered.version, '2.56.1.windows.1');
      expect(pointer.activeVersion, 'PortableGit-2.56.1-64-bit');

      final obsolete = await _createRuntime(
        storage,
        'PortableGit-2.55.0-64-bit',
        '2.55.0.windows.1',
      );
      final maintenance = InstallationMaintenanceService(
        storage: storage,
        logService: logger,
      );
      final scan = await maintenance.scan();
      expect(scan.items.any((item) => item.path == obsolete.path), isTrue);
      await maintenance.cleanup(scan);
      expect(await obsolete.exists(), isFalse);
      expect(await previous.exists(), isTrue);
    },
  );
}

Future<Directory> _createRuntime(
  AppStorageService storage,
  String packageName,
  String gitVersion,
) async {
  final runtime = storage.gitRuntimeVersionDirectory(packageName);
  await Directory('${runtime.path}${Platform.pathSeparator}cmd')
      .create(recursive: true);
  await File(
    '${runtime.path}${Platform.pathSeparator}cmd'
    '${Platform.pathSeparator}git.exe',
  ).writeAsString('git');
  await Directory('${runtime.path}${Platform.pathSeparator}mingw64').create();
  await Directory('${runtime.path}${Platform.pathSeparator}usr').create();
  final licenses = Directory(
    '${runtime.path}${Platform.pathSeparator}licenses',
  );
  await licenses.create();
  await File('${licenses.path}${Platform.pathSeparator}GIT-COPYING.txt')
      .writeAsString('license');
  await File('${licenses.path}${Platform.pathSeparator}PORTABLEGIT-NOTICE.txt')
      .writeAsString('notice');
  await File('${runtime.path}${Platform.pathSeparator}git-runtime.json')
      .writeAsString(
        jsonEncode({
          'runtimeFormat': 1,
          'packageName': packageName,
          'gitVersion': gitVersion,
          'sourceUrl': 'https://example.com/PortableGit.7z.exe',
          'archiveSha256': List.filled(64, 'a').join(),
          'licensePath': 'licenses/GIT-COPYING.txt',
          'noticePath': 'licenses/PORTABLEGIT-NOTICE.txt',
          'builtAt': '2026-11-23T00:00:00Z',
        }),
      );
  return runtime;
}

Future<GitRuntimeSmokeResult> _fakeSmoke(String executablePath) async {
  final runtime = File(executablePath).parent.parent;
  final manifest = GitRuntimeManifest.fromJson(
    jsonDecode(
      await File('${runtime.path}${Platform.pathSeparator}git-runtime.json')
          .readAsString(),
    ) as Map<String, dynamic>,
  );
  return GitRuntimeSmokeResult(
    version: manifest.gitVersion,
    execPath: '${runtime.path}${Platform.pathSeparator}mingw64',
  );
}
