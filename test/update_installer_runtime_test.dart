import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_installation_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_service.dart';
import 'package:git_gui_expand/core/services/update_installer_service.dart';
import 'package:git_gui_expand/core/services/update_service.dart';

import 'support/localized_message_fixture.dart';

void main() {
  late Directory root;
  late AppStorageService storage;
  late AppLogService logger;
  late GitRuntimeManager runtimeManager;
  late GitRuntimeInstallationService runtimeInstallation;
  late UpdateInstallerService installer;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('git_update_runtime_');
    storage = AppStorageService(
      softwareDirectoryOverride: root.path,
      launchedByLauncherOverride: true,
    );
    logger = AppLogService(storage: storage);
    runtimeManager = GitRuntimeManager(
      discovery: GitRuntimeDiscovery(
        storage: storage,
        candidateProvider: () async => const [],
        versionProbe: (_) async => null,
      ),
      logService: logger,
    );
    runtimeInstallation = GitRuntimeInstallationService(
      storage: storage,
      smokeProbe: _fakeRuntimeSmoke,
      stableLinkUpdater: (_, _) async {},
    );
    installer = UpdateInstallerService(
      storage: storage,
      logService: logger,
      runtimeManager: runtimeManager,
      runtimeInstallationService: runtimeInstallation,
    );
  });

  tearDown(() async {
    await logger.flush();
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('standard package update preserves the installed runtime', () async {
    final existingRuntime = await _createRuntime(
      storage,
      'PortableGit-2.56.1-64-bit',
      '2.56.1.windows.1',
    );
    final pointerStore = GitRuntimePointerStore(storage: storage);
    await pointerStore.write(
      GitRuntimePointer(
        activeVersion: 'PortableGit-2.56.1-64-bit',
        activePath: 'versions/PortableGit-2.56.1-64-bit',
        previousVersion: '',
        previousPath: '',
        activatedAt: DateTime.utc(2026, 11, 23),
      ),
    );
    final archive = await _createApplicationArchive(
      root,
      version: '1.2.3',
      includeRuntime: false,
    );
    final release = await _releaseForArchive(archive, '1.2.3');

    final result = await installer.installPreparedArchive(
      release,
      archive,
      onProgress: (_) {},
    );

    expect(result.success, isTrue, reason: fixtureText(result.message));
    expect(
      await storage.versionsDirectory.list().any(
        (entry) => entry.path.endsWith('${Platform.pathSeparator}1.2.3'),
      ),
      isTrue,
    );
    expect(await existingRuntime.exists(), isTrue);
    final pointer = await pointerStore.read();
    expect(pointer.activeVersion, 'PortableGit-2.56.1-64-bit');
  });

  test('PortableGit package activates the packaged runtime', () async {
    final archive = await _createApplicationArchive(
      root,
      version: '1.2.3',
      includeRuntime: true,
    );
    final release = await _releaseForArchive(archive, '1.2.3');

    final result = await installer.installPreparedArchive(
      release,
      archive,
      onProgress: (_) {},
    );

    expect(result.success, isTrue, reason: fixtureText(result.message));
    final pointer = await GitRuntimePointerStore(storage: storage).read();
    expect(pointer.activeVersion, 'PortableGit-2.56.1-64-bit');
    expect(
      await storage.gitRuntimeVersionDirectory(pointer.activeVersion).exists(),
      isTrue,
    );
  });

  test('invalid packaged runtime prevents application activation', () async {
    final archive = await _createApplicationArchive(
      root,
      version: '1.2.3',
      includeRuntime: true,
      corruptRuntime: true,
    );
    final release = await _releaseForArchive(archive, '1.2.3');

    final result = await installer.installPreparedArchive(
      release,
      archive,
      onProgress: (_) {},
    );

    expect(result.success, isFalse);
    expect(fixtureText(result.message), contains('PortableGit'));
    expect(
      await Directory(
        '${storage.versionsDirectory.path}${Platform.pathSeparator}1.2.3',
      ).exists(),
      isFalse,
    );
    expect(await storage.pendingVersionFile.exists(), isFalse);
  });

  test('mirror bytes with a mismatched digest are rejected', () async {
    final archive = await _createApplicationArchive(
      root,
      version: '1.2.3',
      includeRuntime: false,
    );
    final valid = await _releaseForArchive(archive, '1.2.3');
    final release = UpdateCheckResult(
      status: valid.status,
      message: valid.message,
      latestVersion: valid.latestVersion,
      assetName: valid.assetName,
      downloadUrl: valid.downloadUrl,
      sha256: List.filled(64, '0').join(),
      assetSize: valid.assetSize,
      source: UpdateSource.gitee,
    );

    final result = await installer.installPreparedArchive(
      release,
      archive,
      onProgress: (_) {},
    );

    expect(result.success, isFalse);
    expect(fixtureText(result.message), contains('SHA-256'));
    expect(await archive.exists(), isFalse);
  });
}

Future<UpdateCheckResult> _releaseForArchive(
  File archive,
  String version,
) async {
  final installer = UpdateInstallerService();
  final digest = await installer.calculateSha256(archive.path);
  return UpdateCheckResult(
    status: UpdateCheckStatus.updateAvailable,
    message: fixtureMessage('update'),
    latestVersion: version,
    assetName: 'Git_Gui_Expand-v$version-windows-x64.zip',
    downloadUrl:
        'https://github.com/CY68GI/Git_Gui_Expand/releases/download/v$version/package.zip',
    sha256: digest,
    assetSize: await archive.length(),
  );
}

Future<File> _createApplicationArchive(
  Directory root, {
  required String version,
  required bool includeRuntime,
  bool corruptRuntime = false,
}) async {
  final stage = Directory('${root.path}${Platform.pathSeparator}zip-stage');
  if (await stage.exists()) await stage.delete(recursive: true);
  final versionDirectory = Directory(
    '${stage.path}${Platform.pathSeparator}versions'
    '${Platform.pathSeparator}$version',
  );
  final data = Directory(
    '${versionDirectory.path}${Platform.pathSeparator}data',
  );
  final flutterAssets = Directory(
    '${data.path}${Platform.pathSeparator}flutter_assets',
  );
  final maintenance = Directory(
    '${versionDirectory.path}${Platform.pathSeparator}maintenance',
  );
  await flutterAssets.create(recursive: true);
  await maintenance.create(recursive: true);
  for (final file in [
    File('${versionDirectory.path}${Platform.pathSeparator}git_gui_expand.exe'),
    File('${data.path}${Platform.pathSeparator}app.so'),
    File(
      '${maintenance.path}${Platform.pathSeparator}'
      'GitGuiExpandLauncher.exe',
    ),
    File('${versionDirectory.path}${Platform.pathSeparator}version.json'),
  ]) {
    await file.writeAsString('payload');
  }
  await File('${versionDirectory.path}${Platform.pathSeparator}version.json')
      .writeAsString(jsonEncode({'version': version}));
  if (includeRuntime) {
    final packageName = 'PortableGit-2.56.1-64-bit';
    final runtimeRoot = Directory(
      '${stage.path}${Platform.pathSeparator}runtime'
      '${Platform.pathSeparator}git',
    );
    final runtimeVersion = Directory(
      '${runtimeRoot.path}${Platform.pathSeparator}versions'
      '${Platform.pathSeparator}$packageName',
    );
    await Directory('${runtimeVersion.path}${Platform.pathSeparator}cmd')
        .create(recursive: true);
    await File(
      '${runtimeVersion.path}${Platform.pathSeparator}cmd'
      '${Platform.pathSeparator}git.exe',
    ).writeAsString('git');
    await Directory('${runtimeVersion.path}${Platform.pathSeparator}mingw64')
        .create();
    await Directory('${runtimeVersion.path}${Platform.pathSeparator}usr')
        .create();
    final licenses = Directory(
      '${runtimeVersion.path}${Platform.pathSeparator}licenses',
    );
    await licenses.create();
    await File('${licenses.path}${Platform.pathSeparator}GIT-COPYING.txt')
        .writeAsString('license');
    await File(
      '${licenses.path}${Platform.pathSeparator}PORTABLEGIT-NOTICE.txt',
    ).writeAsString('notice');
    if (!corruptRuntime) {
      await File(
        '${runtimeVersion.path}${Platform.pathSeparator}git-runtime.json',
      ).writeAsString(
        jsonEncode({
          'runtimeFormat': 1,
          'packageName': packageName,
          'gitVersion': '2.56.1.windows.1',
          'sourceUrl': 'https://example.com/PortableGit.7z.exe',
          'archiveSha256': List.filled(64, 'a').join(),
          'licensePath': 'licenses/GIT-COPYING.txt',
          'noticePath': 'licenses/PORTABLEGIT-NOTICE.txt',
          'builtAt': '2026-11-23T00:00:00Z',
        }),
      );
    }
    await File('${runtimeRoot.path}${Platform.pathSeparator}current.json')
        .writeAsString(
          jsonEncode({
            'runtimeFormat': 1,
            'activeVersion': packageName,
            'activePath': 'versions/$packageName',
            'previousVersion': '',
            'previousPath': '',
            'activatedAt': '2026-11-23T00:00:00Z',
          }),
        );
  }
  final archive = File(
    '${root.path}${Platform.pathSeparator}'
    'Git_Gui_Expand-v$version-windows-x64'
    '${includeRuntime ? '-PortableGit' : ''}.zip',
  );
  await _zipDirectory(stage, archive);
  return archive;
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

Future<GitRuntimeSmokeResult> _fakeRuntimeSmoke(String executablePath) async {
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

Future<void> _zipDirectory(Directory source, File target) async {
  if (await target.exists()) await target.delete();
  final result = await Process.run('tar.exe', [
    '-a',
    '-c',
    '-f',
    target.path,
    '-C',
    source.path,
    '.',
  ], runInShell: false);
  if (result.exitCode != 0) {
    throw StateError('${result.stdout}\n${result.stderr}');
  }
}
