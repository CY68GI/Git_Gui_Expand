import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/update_installer_service.dart';
import 'package:git_gui_expand/core/services/update_service.dart';

void main() {
  late Directory temporaryDirectory;
  late UpdateService service;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'git_gui_update_',
    );
    final storage = AppStorageService(
      softwareDirectoryOverride: temporaryDirectory.path,
    );
    service = UpdateService(logService: AppLogService(storage: storage));
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('selects a verified Windows x64 release asset', () {
    final asset = service.selectWindowsAsset([
      {
        'name': 'Git_Gui_Expand-v0.5.0-linux-x64.zip',
        'browser_download_url': 'https://github.com/CY68GI/Git_Gui_Expand/releases/download/v0.5.0/linux.zip',
        'digest': 'sha256:${_repeat('a')}',
        'size': 1,
      },
      {
        'name': 'Git_Gui_Expand-v0.5.0-windows-x64.zip',
        'browser_download_url': 'https://github.com/CY68GI/Git_Gui_Expand/releases/download/v0.5.0/windows.zip',
        'digest': 'sha256:${_repeat('b')}',
        'size': 123,
      },
    ]);

    expect(asset, isNotNull);
    expect(asset!.name, contains('windows-x64.zip'));
    expect(asset.sha256, _repeat('b'));
    expect(asset.size, 123);
  });

  test('rejects release assets without GitHub HTTPS URL or SHA-256', () {
    expect(
      service.selectWindowsAsset([
        {
          'name': 'Git_Gui_Expand-v0.5.0-windows-x64.zip',
          'browser_download_url': 'http://example.com/update.zip',
          'digest': 'sha256:${_repeat('c')}',
        },
      ]),
      isNull,
    );
    final asset = service.selectWindowsAsset([
      {
        'name': 'Git_Gui_Expand-v0.5.0-windows-x64.zip',
        'browser_download_url': 'https://github.com/CY68GI/Git_Gui_Expand/releases/download/v0.5.0/windows.zip',
      },
    ]);
    expect(asset?.sha256, isEmpty);
  });

  test('extracts SHA-256 from release asset HTML as API fallback', () {
    final hash = _repeat('d');
    final html =
        '<div>Git_Gui_Expand-v0.5.1-windows-x64.zip</div>'
        '<span>sha256:$hash</span>';

    expect(
      service.extractSha256FromReleasePage(
        html,
        assetName: 'Git_Gui_Expand-v0.5.1-windows-x64.zip',
      ),
      hash,
    );
  });

  test('compares release versions numerically', () {
    expect(service.compareVersions('0.10.0', '0.9.9'), greaterThan(0));
    expect(service.compareVersions('v0.5.0', '0.5'), 0);
    expect(service.compareVersions('0.4.9', '0.5.0'), lessThan(0));
  });

  test(
    'calculates update SHA-256 without depending on shell text encoding',
    () async {
      final file = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}digest-input.bin',
      );
      await file.writeAsString('abc');
      final installer = UpdateInstallerService(
        storage: AppStorageService(
          softwareDirectoryOverride: temporaryDirectory.path,
        ),
      );

      expect(
        await installer.calculateSha256(file.path),
        'ba7816bf8f01cfea414140de5dae2223'
        'b00361a396177a9cb410ff61f20015ad',
      );
    },
  );

  test('launcher configuration and version markers are present', () async {
    final launcherSource = await File(
      '${Directory.current.path}${Platform.pathSeparator}windows'
      '${Platform.pathSeparator}launcher${Platform.pathSeparator}main.cpp',
    ).readAsString();
    final cmake = await File(
      '${Directory.current.path}${Platform.pathSeparator}windows'
      '${Platform.pathSeparator}runner${Platform.pathSeparator}CMakeLists.txt',
    ).readAsString();

    expect(launcherSource, contains('pending-version.txt'));
    expect(launcherSource, contains('current-version.txt'));
    expect(launcherSource, contains('GIT_GUI_EXPAND_ROOT'));
    expect(launcherSource, contains('rollback-version.txt'));
    expect(launcherSource, contains('PruneOldVersionDirectories'));
    expect(launcherSource, contains('previousVersion'));
    expect(launcherSource, contains('Removed old version directory'));
    expect(launcherSource, contains('DiscoverCurrentVersion'));
    expect(launcherSource, contains('DiscoverPreviousVersion'));
    expect(launcherSource, contains('TryBuildFlatLaunchPlan'));
    expect(launcherSource, contains('0xEF'));
    expect(cmake, contains('GitGuiExpandLauncher'));
  });

  test(
    'release packaging script parses and writes marker without BOM',
    () async {
      if (!Platform.isWindows) return;
      final script = File(
        '${Directory.current.path}${Platform.pathSeparator}tool'
        '${Platform.pathSeparator}package_windows_release.ps1',
      );
      final source = await script.readAsString();
      final result = await Process.run(
        'pwsh',
        [
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          r'[scriptblock]::Create([IO.File]::ReadAllText($env:PACKAGE_SCRIPT)) | Out-Null',
        ],
        environment: {'PACKAGE_SCRIPT': script.path},
        includeParentEnvironment: true,
        runInShell: false,
      );

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      expect(source, contains(r'UTF8Encoding]::new($false)'));
      expect(source, contains('"current-version.txt"'));
      expect(source, contains('"LICENSE"'));
    },
  );

  test('release notes include only the previous-tag commit range', () async {
    if (!Platform.isWindows) return;
    final output = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}release-notes.md',
    );
    final result = await Process.run(
      'pwsh',
      [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        'tool\\generate_release_notes.ps1',
        '-Tag',
        'v0.5.0',
        '-OutputPath',
        output.path,
      ],
      workingDirectory: Directory.current.path,
      runInShell: false,
    );

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final notes = await output.readAsString();
    expect(notes, contains('v0.4.0 到 v0.5.0 之间的更新'));
    expect(notes, contains('changes from v0.4.0 to v0.5.0'));
    expect(notes, contains('v0.4.0 到 v0.5.0 之間的更新'));
    expect(notes, contains('- feat: add verified automatic updates'));
    expect(notes, isNot(contains('## 0.2.1')));
  });

  test('Gitee upload script parses successfully', () async {
    if (!Platform.isWindows) return;
    final script = File(
      '${Directory.current.path}${Platform.pathSeparator}tool'
      '${Platform.pathSeparator}upload_gitee_release.ps1',
    );
    final result = await Process.run(
      'pwsh',
      [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'[scriptblock]::Create([IO.File]::ReadAllText($env:GITEE_UPLOAD_SCRIPT)) | Out-Null',
      ],
      environment: {'GITEE_UPLOAD_SCRIPT': script.path},
      includeParentEnvironment: true,
      runInShell: false,
    );

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });
}

String _repeat(String character) => List.filled(64, character).join();
