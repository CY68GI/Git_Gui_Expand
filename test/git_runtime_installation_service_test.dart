import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_installation_service.dart';

void main() {
  late Directory root;
  late AppStorageService storage;
  late Directory runtime;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('git_runtime_validation_');
    storage = AppStorageService(softwareDirectoryOverride: root.path);
    runtime = await _createRuntime(storage, 'PortableGit-2.56.1-64-bit');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'accepts a complete PortableGit runtime and matching smoke result',
    () async {
      final service = GitRuntimeInstallationService(
        storage: storage,
        smokeProbe: (executable) async => GitRuntimeSmokeResult(
          version: '2.56.1.windows.1',
          execPath:
              '${runtime.path}${Platform.pathSeparator}mingw64'
              '${Platform.pathSeparator}libexec'
              '${Platform.pathSeparator}git-core',
        ),
      );

      final validated = await service.validate(runtime);

      expect(validated.version, 'PortableGit-2.56.1-64-bit');
      expect(validated.manifest.gitVersion, '2.56.1.windows.1');
      expect(await validated.executable.exists(), isTrue);
    },
  );

  test('rejects a runtime without cmd/git.exe', () async {
    await File(
      '${runtime.path}${Platform.pathSeparator}cmd'
      '${Platform.pathSeparator}git.exe',
    ).delete();

    await expectLater(
      GitRuntimeInstallationService(storage: storage).validate(runtime),
      throwsA(
        isA<GitRuntimeValidationException>().having(
          (error) => error.message,
          'message',
          contains('cmd/git.exe'),
        ),
      ),
    );
  });

  test('rejects missing required roots and notices', () async {
    await Directory('${runtime.path}${Platform.pathSeparator}usr')
        .delete(recursive: true);
    await expectLater(
      GitRuntimeInstallationService(storage: storage).validate(runtime),
      throwsA(
        isA<GitRuntimeValidationException>().having(
          (error) => error.message,
          'message',
          contains('usr'),
        ),
      ),
    );

    await Directory('${runtime.path}${Platform.pathSeparator}usr').create();
    await File(
      '${runtime.path}${Platform.pathSeparator}licenses'
      '${Platform.pathSeparator}GIT-COPYING.txt',
    ).delete();
    await expectLater(
      GitRuntimeInstallationService(storage: storage).validate(runtime),
      throwsA(
        isA<GitRuntimeValidationException>().having(
          (error) => error.message,
          'message',
          contains('GIT-COPYING'),
        ),
      ),
    );
  });

  test('rejects malformed manifests and version mismatches', () async {
    final manifest = storage.gitRuntimeManifestFile(
      'PortableGit-2.56.1-64-bit',
    );
    await manifest.writeAsString('{broken');
    await expectLater(
      GitRuntimeInstallationService(storage: storage).validate(runtime),
      throwsA(isA<GitRuntimeValidationException>()),
    );

    await _writeManifest(runtime, gitVersion: '2.56.1.windows.1');
    await expectLater(
      GitRuntimeInstallationService(
        storage: storage,
        smokeProbe: (_) async => GitRuntimeSmokeResult(
          version: '2.55.0',
          execPath: '${runtime.path}${Platform.pathSeparator}mingw64',
        ),
      ).validate(runtime),
      throwsA(
        isA<GitRuntimeValidationException>().having(
          (error) => error.message,
          'message',
          contains('version mismatch'),
        ),
      ),
    );
  });

  test('rejects an exec-path outside the bundled runtime', () async {
    await expectLater(
      GitRuntimeInstallationService(
        storage: storage,
        smokeProbe: (_) async => const GitRuntimeSmokeResult(
          version: '2.56.1.windows.1',
          execPath: r'C:\Program Files\Git\mingw64\libexec\git-core',
        ),
      ).validate(runtime),
      throwsA(
        isA<GitRuntimeValidationException>().having(
          (error) => error.message,
          'message',
          contains('exec-path'),
        ),
      ),
    );
  });

  test(
    'activates runtimes atomically and retains the previous version',
    () async {
      final versionOne = await _createRuntime(
        storage,
        'PortableGit-2.56.1-64-bit',
        gitVersion: '2.56.1.windows.1',
      );
      final versionTwo = await _createRuntime(
        storage,
        'PortableGit-2.57.0-64-bit',
        gitVersion: '2.57.0.windows.1',
      );
      final linkedTargets = <String>[];
      final service = GitRuntimeInstallationService(
        storage: storage,
        smokeProbe: _fakeSmokeProbe,
        stableLinkUpdater: (_, target) async => linkedTargets.add(target.path),
      );

      final first = await service.validate(versionOne);
      await service.activate(first);
      var pointer = await service.readPointer();
      expect(pointer.activeVersion, 'PortableGit-2.56.1-64-bit');
      expect(pointer.hasPrevious, isFalse);

      final second = await service.validate(versionTwo);
      await service.activate(second);
      pointer = await service.readPointer();
      expect(pointer.activeVersion, 'PortableGit-2.57.0-64-bit');
      expect(pointer.previousVersion, 'PortableGit-2.56.1-64-bit');
      expect(linkedTargets.last, versionTwo.path);
    },
  );

  test(
    'an interrupted pointer commit preserves the previous pointer',
    () async {
      final versionOne = await _createRuntime(
        storage,
        'PortableGit-2.56.1-64-bit',
        gitVersion: '2.56.1.windows.1',
      );
      final versionTwo = await _createRuntime(
        storage,
        'PortableGit-2.57.0-64-bit',
        gitVersion: '2.57.0.windows.1',
      );
      final stableStore = GitRuntimePointerStore(storage: storage);
      await stableStore.write(
        GitRuntimePointer(
          activeVersion: 'PortableGit-2.56.1-64-bit',
          activePath: 'versions/PortableGit-2.56.1-64-bit',
          previousVersion: '',
          previousPath: '',
          activatedAt: DateTime.utc(2026, 11, 23),
        ),
      );
      final failingStore = GitRuntimePointerStore(
        storage: storage,
        committer: (temporary, target) async {
          throw const FileSystemException(
            'simulated interrupted pointer write',
          );
        },
      );
      final linkedTargets = <String>[];
      final service = GitRuntimeInstallationService(
        storage: storage,
        smokeProbe: _fakeSmokeProbe,
        pointerStore: failingStore,
        stableLinkUpdater: (_, target) async => linkedTargets.add(target.path),
      );

      final second = await service.validate(versionTwo);
      await expectLater(
        service.activate(second),
        throwsA(isA<FileSystemException>()),
      );

      final pointer = await stableStore.read();
      expect(pointer.activeVersion, 'PortableGit-2.56.1-64-bit');
      expect(linkedTargets.last, versionOne.path);
    },
  );

  test(
    'restores the previous runtime when the active runtime is corrupt',
    () async {
      final previous = await _createRuntime(
        storage,
        'PortableGit-2.56.1-64-bit',
        gitVersion: '2.56.1.windows.1',
      );
      final active = await _createRuntime(
        storage,
        'PortableGit-2.57.0-64-bit',
        gitVersion: '2.57.0.windows.1',
      );
      final pointerStore = GitRuntimePointerStore(storage: storage);
      await pointerStore.write(
        GitRuntimePointer(
          activeVersion: 'PortableGit-2.57.0-64-bit',
          activePath: 'versions/PortableGit-2.57.0-64-bit',
          previousVersion: 'PortableGit-2.56.1-64-bit',
          previousPath: 'versions/PortableGit-2.56.1-64-bit',
          activatedAt: DateTime.utc(2026, 11, 23),
        ),
      );
      await File('${active.path}${Platform.pathSeparator}git-runtime.json')
          .delete();
      final linkedTargets = <String>[];
      final service = GitRuntimeInstallationService(
        storage: storage,
        smokeProbe: _fakeSmokeProbe,
        pointerStore: pointerStore,
        stableLinkUpdater: (_, target) async => linkedTargets.add(target.path),
      );

      final restored = await service.restorePrevious();
      final pointer = await pointerStore.read();

      expect(restored.directory.path, previous.path);
      expect(pointer.activeVersion, 'PortableGit-2.56.1-64-bit');
      expect(pointer.hasPrevious, isFalse);
      expect(linkedTargets.last, previous.path);
    },
  );
}

Future<Directory> _createRuntime(
  AppStorageService storage,
  String packageName, {
  String gitVersion = '2.56.1.windows.1',
}) async {
  final runtime = storage.gitRuntimeVersionDirectory(packageName);
  await Directory('${runtime.path}${Platform.pathSeparator}cmd')
      .create(recursive: true);
  await File(
    '${runtime.path}${Platform.pathSeparator}cmd'
    '${Platform.pathSeparator}git.exe',
  ).writeAsString('fake git');
  await Directory('${runtime.path}${Platform.pathSeparator}mingw64').create();
  await Directory('${runtime.path}${Platform.pathSeparator}usr').create();
  final licenses = Directory(
    '${runtime.path}${Platform.pathSeparator}licenses',
  );
  await licenses.create();
  await File('${licenses.path}${Platform.pathSeparator}GIT-COPYING.txt')
      .writeAsString('Git license');
  await File('${licenses.path}${Platform.pathSeparator}PORTABLEGIT-NOTICE.txt')
      .writeAsString('PortableGit source notice');
  await _writeManifest(runtime, gitVersion: gitVersion);
  return runtime;
}

Future<GitRuntimeSmokeResult> _fakeSmokeProbe(String executablePath) async {
  final versionDirectory = File(executablePath).parent.parent;
  final manifestText = await File(
    '${versionDirectory.path}${Platform.pathSeparator}git-runtime.json',
  ).readAsString();
  final manifest = GitRuntimeManifest.fromJson(
    jsonDecode(manifestText) as Map<String, dynamic>,
  );
  return GitRuntimeSmokeResult(
    version: manifest.gitVersion,
    execPath:
        '${versionDirectory.path}${Platform.pathSeparator}mingw64'
        '${Platform.pathSeparator}libexec'
        '${Platform.pathSeparator}git-core',
  );
}

Future<void> _writeManifest(
  Directory runtime, {
  required String gitVersion,
}) async {
  final payload = const JsonEncoder.withIndent('  ').convert({
    'runtimeFormat': 1,
    'packageName': runtime.path.split(Platform.pathSeparator).last,
    'gitVersion': gitVersion,
    'sourceUrl':
        'https://github.com/git-for-windows/git/releases/download/'
        'v2.56.1.windows.1/PortableGit.7z.exe',
    'archiveSha256': List.filled(64, 'a').join(),
    'licensePath': 'licenses/GIT-COPYING.txt',
    'noticePath': 'licenses/PORTABLEGIT-NOTICE.txt',
    'builtAt': '2026-11-23T00:00:00Z',
  });
  await File('${runtime.path}${Platform.pathSeparator}git-runtime.json')
      .writeAsString(payload);
}
