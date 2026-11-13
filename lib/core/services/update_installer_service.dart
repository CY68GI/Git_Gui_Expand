import 'dart:convert';
import 'dart:io';

import '../constants/app_info.dart';
import 'app_log_service.dart';
import 'app_storage_service.dart';
import 'update_service.dart';

class UpdateInstallProgress {
  const UpdateInstallProgress({
    required this.stage,
    required this.message,
    this.percent,
  });

  final String stage;
  final String message;
  final double? percent;
}

class UpdateInstallResult {
  const UpdateInstallResult.success(this.message) : success = true;
  const UpdateInstallResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}

class UpdateInstallerService {
  UpdateInstallerService({
    this.storage = const AppStorageService(),
    AppLogService? logService,
  }) : logService = logService ?? AppLogService.instance;

  final AppStorageService storage;
  final AppLogService logService;

  Future<UpdateInstallResult> install(
    UpdateCheckResult release, {
    required void Function(UpdateInstallProgress progress) onProgress,
  }) async {
    if (!Platform.isWindows) {
      return const UpdateInstallResult.failure('当前自动更新仅支持 Windows。');
    }
    if (release.status != UpdateCheckStatus.updateAvailable) {
      return const UpdateInstallResult.failure('当前没有可安装的新版本。');
    }
    if (release.downloadUrl.isEmpty ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(release.sha256)) {
      return const UpdateInstallResult.failure(
        '更新资产缺少下载地址或有效 SHA-256，已取消自动更新。',
      );
    }

    final updatesRoot = Directory(
      '${storage.dataDirectory.path}${Platform.pathSeparator}updates',
    );
    try {
      await updatesRoot.create(recursive: true);
      final safeVersion = release.latestVersion.replaceAll(
        RegExp(r'[^A-Za-z0-9._-]'),
        '_',
      );
      final archive = File(
        '${updatesRoot.path}${Platform.pathSeparator}'
        'Git_Gui_Expand-v$safeVersion.zip',
      );
      final staging = Directory(
        '${updatesRoot.path}${Platform.pathSeparator}stage-v$safeVersion',
      );
      final script = File(
        '${updatesRoot.path}${Platform.pathSeparator}apply-update.ps1',
      );
      final updaterLog = File(
        '${updatesRoot.path}${Platform.pathSeparator}updater.log',
      );

      await _deleteDirectoryIfExists(staging);
      await _deleteFileIfExists(archive);
      onProgress(
        const UpdateInstallProgress(
          stage: 'download',
          message: '正在连接 GitHub 下载更新…',
          percent: 0,
        ),
      );
      await _download(
        release,
        archive,
        onProgress: (percent) {
          onProgress(
            UpdateInstallProgress(
              stage: 'download',
              message: '正在下载 ${release.assetName}…',
              percent: percent,
            ),
          );
        },
      );

      onProgress(
        const UpdateInstallProgress(
          stage: 'verify',
          message: '正在校验更新包 SHA-256…',
        ),
      );
      final actualHash = await _sha256(archive.path);
      if (actualHash.toLowerCase() != release.sha256.toLowerCase()) {
        await _deleteFileIfExists(archive);
        throw const FormatException('更新包 SHA-256 校验失败');
      }
      logService.info('update', '更新包 SHA-256 校验通过：$actualHash');

      onProgress(
        const UpdateInstallProgress(stage: 'extract', message: '正在解压更新包…'),
      );
      await staging.create(recursive: true);
      await _extract(archive.path, staging.path);
      await _validateStaging(staging, release.latestVersion);

      onProgress(
        const UpdateInstallProgress(stage: 'prepare', message: '正在准备安全替换与重启…'),
      );
      await script.writeAsString(updaterScript, flush: true);
      await updaterLog.writeAsString(
        '${DateTime.now().toIso8601String()} '
        'Preparing update to v${release.latestVersion}\n',
        mode: FileMode.append,
        flush: true,
      );
      await Process.start(
        'powershell.exe',
        [
          '-NoProfile',
          '-WindowStyle',
          'Hidden',
          '-ExecutionPolicy',
          'Bypass',
          '-File',
          script.path,
          '-ParentPid',
          pid.toString(),
          '-SoftwareDir',
          storage.softwareDirectory,
          '-StageDir',
          staging.path,
          '-ArchivePath',
          archive.path,
          '-LogPath',
          updaterLog.path,
        ],
        mode: ProcessStartMode.detached,
        runInShell: false,
      );
      logService.info('update', '更新助手已启动，应用即将退出并重启到 v${release.latestVersion}');
      return UpdateInstallResult.success(
        '更新助手已启动，应用将自动重启到 v${release.latestVersion}。',
      );
    } catch (error) {
      logService.error('update', '自动更新失败：$error');
      return UpdateInstallResult.failure('自动更新失败：$error');
    }
  }

  Future<void> _download(
    UpdateCheckResult release,
    File target, {
    required void Function(double progress) onProgress,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..userAgent = 'GitGUIExpand/${AppInfo.version} AutoUpdater';
    final partial = File('${target.path}.part');
    IOSink? sink;
    try {
      final request = await client
          .getUrl(Uri.parse(release.downloadUrl))
          .timeout(const Duration(seconds: 20));
      request.headers.set(HttpHeaders.acceptHeader, 'application/octet-stream');
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('下载返回 HTTP ${response.statusCode}');
      }
      final expected = response.contentLength > 0
          ? response.contentLength
          : release.assetSize;
      var received = 0;
      await _deleteFileIfExists(partial);
      sink = partial.openWrite(mode: FileMode.write);
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (expected > 0) {
          onProgress((received / expected).clamp(0.0, 1.0));
        }
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (received == 0) {
        throw const FileSystemException('下载文件为空');
      }
      await partial.rename(target.path);
      onProgress(1);
      logService.detail(
        'update',
        '下载完成：${target.path} bytes=$received expected=$expected',
      );
    } catch (error) {
      await sink?.close();
      await _deleteFileIfExists(partial);
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _extract(String archivePath, String destination) async {
    final result = await Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'''
$ErrorActionPreference = 'Stop'
Expand-Archive -LiteralPath $env:GIT_GUI_UPDATE_ZIP `
  -DestinationPath $env:GIT_GUI_UPDATE_STAGE -Force
''',
      ],
      environment: {
        'GIT_GUI_UPDATE_ZIP': archivePath,
        'GIT_GUI_UPDATE_STAGE': destination,
      },
      includeParentEnvironment: true,
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw FileSystemException(
        '解压更新包失败：${(result.stderr as String).trim()}',
        archivePath,
      );
    }
  }

  Future<String> _sha256(String filePath) async {
    final result = await Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'''
$ErrorActionPreference = 'Stop'
(Get-FileHash -LiteralPath $env:GIT_GUI_UPDATE_FILE `
  -Algorithm SHA256).Hash
''',
      ],
      environment: {'GIT_GUI_UPDATE_FILE': filePath},
      includeParentEnvironment: true,
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw FileSystemException(
        '计算更新包 SHA-256 失败：${(result.stderr as String).trim()}',
        filePath,
      );
    }
    return (result.stdout as String).trim();
  }

  Future<void> _validateStaging(
    Directory staging,
    String expectedVersion,
  ) async {
    final executable = File(
      '${staging.path}${Platform.pathSeparator}git_gui_expand.exe',
    );
    final data = Directory('${staging.path}${Platform.pathSeparator}data');
    final versionFile = File(
      '${staging.path}${Platform.pathSeparator}version.json',
    );
    if (!await executable.exists() || !await data.exists()) {
      throw const FileSystemException('更新包缺少应用程序或 Flutter 数据目录');
    }
    if (!await versionFile.exists()) {
      throw const FileSystemException('更新包缺少 version.json');
    }
    final decoded = jsonDecode(await versionFile.readAsString());
    final version = decoded is Map<String, dynamic>
        ? (decoded['version'] as String? ?? '')
        : '';
    if (version != expectedVersion) {
      throw FormatException('更新包版本不匹配：包内 $version，Release $expectedVersion');
    }
  }

  Future<void> _deleteDirectoryIfExists(Directory directory) async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<void> _deleteFileIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  static const String updaterScript = r'''
param(
  [Parameter(Mandatory = $true)][int]$ParentPid,
  [Parameter(Mandatory = $true)][string]$SoftwareDir,
  [Parameter(Mandatory = $true)][string]$StageDir,
  [Parameter(Mandatory = $true)][string]$ArchivePath,
  [Parameter(Mandatory = $true)][string]$LogPath
)

$ErrorActionPreference = 'Stop'

function Write-UpdaterLog {
  param([string]$Message)
  $line = "$(Get-Date -Format o) $Message"
  Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
}

function Remove-AppItems {
  Get-ChildItem -LiteralPath $SoftwareDir -Force |
    Where-Object { $_.Name -ne 'userdata' } |
    ForEach-Object {
      Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }
}

Write-UpdaterLog "Waiting for parent process $ParentPid"
$deadline = (Get-Date).AddSeconds(120)
while (Get-Process -Id $ParentPid -ErrorAction SilentlyContinue) {
  if ((Get-Date) -gt $deadline) {
    Write-UpdaterLog 'Timed out waiting for application to exit'
    exit 1
  }
  Start-Sleep -Milliseconds 500
}

$updatesRoot = Join-Path $SoftwareDir 'userdata\updates'
$backupRoot = Join-Path $updatesRoot 'backups'
New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
$backupDir = Join-Path $backupRoot ("backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
$exePath = Join-Path $SoftwareDir 'git_gui_expand.exe'

try {
  Write-UpdaterLog "Creating backup at $backupDir"
  Get-ChildItem -LiteralPath $SoftwareDir -Force |
    Where-Object { $_.Name -ne 'userdata' } |
    ForEach-Object {
      Copy-Item -LiteralPath $_.FullName -Destination $backupDir -Recurse -Force
    }

  Write-UpdaterLog 'Removing previous application files'
  Remove-AppItems
  Write-UpdaterLog "Copying staged update from $StageDir"
  Get-ChildItem -LiteralPath $StageDir -Force |
    Copy-Item -Destination $SoftwareDir -Recurse -Force

  if (-not (Test-Path -LiteralPath $exePath -PathType Leaf)) {
    throw 'Updated executable is missing'
  }

  $newProcess = Start-Process -FilePath $exePath -WorkingDirectory $SoftwareDir -PassThru
  Start-Sleep -Seconds 2
  if ($newProcess.HasExited) {
    throw "Updated application exited during startup with code $($newProcess.ExitCode)"
  }
  Write-UpdaterLog 'Update installed; application restarted'
  Remove-Item -LiteralPath $StageDir -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $ArchivePath -Force -ErrorAction SilentlyContinue

  Get-ChildItem -LiteralPath $backupRoot -Directory |
    Sort-Object LastWriteTime -Descending |
    Select-Object -Skip 2 |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} catch {
  Write-UpdaterLog "Update failed: $($_.Exception.Message)"
  try {
    Remove-AppItems
    Get-ChildItem -LiteralPath $backupDir -Force |
      Copy-Item -Destination $SoftwareDir -Recurse -Force
    if (Test-Path -LiteralPath $exePath -PathType Leaf) {
      Start-Process -FilePath $exePath -WorkingDirectory $SoftwareDir
    }
    Write-UpdaterLog 'Rollback completed'
  } catch {
    Write-UpdaterLog "Rollback failed: $($_.Exception.Message)"
  }
  exit 1
}
''';
}
