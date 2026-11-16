import 'dart:convert';
import 'dart:io';

import 'app_log_service.dart';
import 'app_storage_service.dart';

class DesktopShortcutResult {
  const DesktopShortcutResult.success(this.message, this.shortcutPath)
    : isSuccess = true;

  const DesktopShortcutResult.failure(this.message)
    : isSuccess = false,
      shortcutPath = null;

  final bool isSuccess;
  final String message;
  final String? shortcutPath;
}

class DesktopShortcutService {
  const DesktopShortcutService({
    this.storage = const AppStorageService(),
    this.logService,
    this.desktopDirectoryOverride,
  });

  final AppStorageService storage;
  final AppLogService? logService;
  final String? desktopDirectoryOverride;

  AppLogService get _log => logService ?? AppLogService.instance;

  Future<DesktopShortcutResult> create() async {
    if (!Platform.isWindows) {
      return const DesktopShortcutResult.failure('创建桌面快捷方式目前仅支持 Windows。');
    }

    final launcher = storage.launcherFile;
    final target = await launcher.exists()
        ? launcher
        : File(Platform.resolvedExecutable);
    if (!await target.exists()) {
      return DesktopShortcutResult.failure('找不到可创建快捷方式的程序：${target.path}');
    }

    final result = await Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        r'''
$ErrorActionPreference = 'Stop'
$desktop = $env:GIT_GUI_SHORTCUT_DESKTOP
if ([string]::IsNullOrWhiteSpace($desktop)) {
  $desktop = [Environment]::GetFolderPath('Desktop')
}
if ([string]::IsNullOrWhiteSpace($desktop)) {
  throw '无法获取当前用户的桌面目录'
}
if (-not (Test-Path -LiteralPath $desktop)) {
  New-Item -ItemType Directory -Path $desktop -Force | Out-Null
}
$shortcutPath = Join-Path $desktop 'Git GUI Expand.lnk'
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $env:GIT_GUI_SHORTCUT_TARGET
$shortcut.WorkingDirectory = $env:GIT_GUI_SHORTCUT_WORKDIR
$shortcut.IconLocation = "$env:GIT_GUI_SHORTCUT_TARGET,0"
$shortcut.Description = 'Git GUI Expand'
$shortcut.Save()
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
Write-Output $shortcutPath
''',
      ],
      environment: {
        'GIT_GUI_SHORTCUT_TARGET': target.path,
        'GIT_GUI_SHORTCUT_WORKDIR': storage.softwareDirectory,
        'GIT_GUI_SHORTCUT_DESKTOP': desktopDirectoryOverride ?? '',
      },
      includeParentEnvironment: true,
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      final error = (result.stderr as String).trim();
      _log.error('shortcut', '创建桌面快捷方式失败：$error');
      return DesktopShortcutResult.failure(
        error.isEmpty ? '创建桌面快捷方式失败。' : error,
      );
    }
    final shortcutPath = (result.stdout as String).trim();
    _log.info('shortcut', '已创建桌面快捷方式：$shortcutPath');
    return DesktopShortcutResult.success(
      '已创建桌面快捷方式：$shortcutPath',
      shortcutPath,
    );
  }
}
