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

  test('generated PowerShell updater script parses successfully', () async {
    if (!Platform.isWindows) return;
    final script = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}apply-update.ps1',
    );
    await script.writeAsString(UpdateInstallerService.updaterScript);
    final result = await Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'[scriptblock]::Create([IO.File]::ReadAllText($env:UPDATE_SCRIPT)) | Out-Null',
      ],
      environment: {'UPDATE_SCRIPT': script.path},
      includeParentEnvironment: true,
      runInShell: false,
    );

    expect(result.exitCode, 0);
    expect((result.stderr as String).trim(), isEmpty);
  });
}

String _repeat(String character) => List.filled(64, character).join();
