import 'dart:convert';
import 'dart:io';

import '../constants/app_info.dart';
import 'app_log_service.dart';
import 'app_storage_service.dart';

class ExecutableVersionInfo {
  const ExecutableVersionInfo({
    required this.applicationVersion,
    required this.launcherVersion,
    required this.applicationPath,
    required this.launcherPath,
  });

  final String applicationVersion;
  final String launcherVersion;
  final String applicationPath;
  final String launcherPath;
}

class ExecutableVersionService {
  const ExecutableVersionService({
    this.storage = const AppStorageService(),
    this.logService,
  });

  final AppStorageService storage;
  final AppLogService? logService;

  AppLogService get _log => logService ?? AppLogService.instance;

  Future<ExecutableVersionInfo> load() async {
    final applicationPath = File(Platform.resolvedExecutable).absolute.path;
    final launcherPath = storage.launcherFile.absolute.path;
    var applicationVersion = AppInfo.version;
    var launcherVersion = '';
    if (Platform.isWindows) {
      try {
        final result = await Process.run(
          'powershell.exe',
          [
            '-NoProfile',
            '-NonInteractive',
            '-ExecutionPolicy',
            'Bypass',
            '-Command',
            r'''
$app = $env:GIT_GUI_VERSION_APP
$launcher = $env:GIT_GUI_VERSION_LAUNCHER
$appVersion = if (Test-Path -LiteralPath $app) {
  (Get-Item -LiteralPath $app).VersionInfo.FileVersion
} else { '' }
$launcherVersion = if (Test-Path -LiteralPath $launcher) {
  (Get-Item -LiteralPath $launcher).VersionInfo.FileVersion
} else { '' }
@{
  app = $appVersion
  launcher = $launcherVersion
} | ConvertTo-Json -Compress
''',
          ],
          environment: {
            'GIT_GUI_VERSION_APP': applicationPath,
            'GIT_GUI_VERSION_LAUNCHER': launcherPath,
          },
          includeParentEnvironment: true,
          runInShell: false,
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );
        if (result.exitCode == 0) {
          final decoded = jsonDecode((result.stdout as String).trim());
          if (decoded is Map<String, dynamic>) {
            applicationVersion =
                (decoded['app'] as String? ?? '').trim().isEmpty
                ? AppInfo.version
                : (decoded['app'] as String).trim();
            launcherVersion = (decoded['launcher'] as String? ?? '').trim();
          }
        }
      } catch (error) {
        _log.warning('version', '读取可执行文件版本失败：$error');
      }
    } else {
      launcherVersion = '';
    }
    return ExecutableVersionInfo(
      applicationVersion: applicationVersion,
      launcherVersion: launcherVersion,
      applicationPath: applicationPath,
      launcherPath: launcherPath,
    );
  }
}
