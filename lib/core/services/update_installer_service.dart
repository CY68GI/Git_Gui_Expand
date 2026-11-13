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
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(release.latestVersion)) {
      return const UpdateInstallResult.failure('更新版本号包含非法字符。');
    }

    final version = release.latestVersion;
    final updatesRoot = Directory(
      '${storage.dataDirectory.path}${Platform.pathSeparator}updates',
    );
    final versionsRoot = storage.versionsDirectory;
    final archive = File(
      '${updatesRoot.path}${Platform.pathSeparator}'
      'Git_Gui_Expand-v$version.zip',
    );
    final staging = Directory(
      '${updatesRoot.path}${Platform.pathSeparator}stage-v$version',
    );
    final target = Directory(
      '${versionsRoot.path}${Platform.pathSeparator}$version',
    );

    try {
      await updatesRoot.create(recursive: true);
      await versionsRoot.create(recursive: true);
      await _deleteDirectoryIfExists(staging);
      await _deleteFileIfExists(archive);

      onProgress(
        const UpdateInstallProgress(
          stage: 'download',
          message: '正在连接 Release 下载更新…',
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
        const UpdateInstallProgress(stage: 'extract', message: '正在解压到独立版本目录…'),
      );
      await staging.create(recursive: true);
      await _extract(archive.path, staging.path);
      final payload = await _resolvePayloadDirectory(staging, version);
      await _validatePayload(payload, version);

      if (await target.exists()) {
        try {
          await _validatePayload(target, version);
          await _deleteDirectoryIfExists(staging);
        } catch (_) {
          await _deleteDirectoryIfExists(target);
        }
      }

      if (await target.exists()) {
        logService.info('update', '版本 $version 已存在，复用现有版本目录');
      } else {
        final nestedPayload = payload.path != staging.path;
        await payload.rename(target.path);
        if (nestedPayload && await staging.exists()) {
          await _deleteDirectoryIfExists(staging);
        }
        logService.info('update', '新版本已准备到 ${target.path}');
      }

      onProgress(
        const UpdateInstallProgress(
          stage: 'prepare',
          message: '正在通知 Launcher 切换版本…',
          percent: 1,
        ),
      );
      await _writePendingVersion(version);
      await logService.flush();

      if (!storage.isLaunchedByLauncher) {
        final launcher = File(
          '${storage.softwareDirectory}${Platform.pathSeparator}'
          'GitGuiExpandLauncher.exe',
        );
        if (!await launcher.exists()) {
          throw FileSystemException(
            '未找到 GitGuiExpandLauncher.exe；新版本已准备好，请手动打开 Launcher',
            launcher.path,
          );
        }
        await Process.start(
          launcher.path,
          ['--wait-pid', pid.toString()],
          mode: ProcessStartMode.normal,
          runInShell: false,
        );
      }

      logService.info('update', '版本 $version 已就绪，等待应用退出后由 Launcher 重启');
      return UpdateInstallResult.success(
        '新版本 v$version 已准备完成，应用退出后 Launcher 将自动切换并重启。',
      );
    } catch (error) {
      logService.error('update', 'Launcher 更新准备失败：$error');
      return UpdateInstallResult.failure('更新准备失败：$error');
    }
  }

  Future<Directory> _resolvePayloadDirectory(
    Directory staging,
    String version,
  ) async {
    final rootVersion = File(
      '${staging.path}${Platform.pathSeparator}version.json',
    );
    if (await rootVersion.exists()) {
      return staging;
    }
    final nested = Directory(
      '${staging.path}${Platform.pathSeparator}versions'
      '${Platform.pathSeparator}$version',
    );
    if (await nested.exists()) {
      return nested;
    }
    throw const FileSystemException('更新包中找不到目标版本的应用程序目录');
  }

  Future<void> _validatePayload(
    Directory payload,
    String expectedVersion,
  ) async {
    final executable = File(
      '${payload.path}${Platform.pathSeparator}git_gui_expand.exe',
    );
    final appData = File(
      '${payload.path}${Platform.pathSeparator}data'
      '${Platform.pathSeparator}app.so',
    );
    final flutterData = Directory(
      '${payload.path}${Platform.pathSeparator}data'
      '${Platform.pathSeparator}flutter_assets',
    );
    final versionFile = File(
      '${payload.path}${Platform.pathSeparator}version.json',
    );
    if (!await executable.exists() ||
        !await appData.exists() ||
        !await flutterData.exists()) {
      throw const FileSystemException('新版本目录缺少应用运行文件');
    }
    if (!await versionFile.exists()) {
      throw const FileSystemException('新版本目录缺少 version.json');
    }
    final decoded = jsonDecode(await versionFile.readAsString());
    final version = decoded is Map<String, dynamic>
        ? (decoded['version'] as String? ?? '')
        : '';
    if (version != expectedVersion) {
      throw FormatException('更新包版本不匹配：包内 $version，Release $expectedVersion');
    }
  }

  Future<void> _writePendingVersion(String version) async {
    await storage.pendingVersionFile.writeAsString('$version\n', flush: true);
  }

  Future<void> _download(
    UpdateCheckResult release,
    File target, {
    required void Function(double progress) onProgress,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..userAgent = 'GitGUIExpand/${AppInfo.version} LauncherUpdater';
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
        '-ExecutionPolicy',
        'Bypass',
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
        '-ExecutionPolicy',
        'Bypass',
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
}
