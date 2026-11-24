import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../constants/app_info.dart';
import '../localization/localized_message.dart';
import '../localization/runtime_messages.dart';
import 'app_log_service.dart';
import 'app_storage_service.dart';
import 'git_runtime_installation_service.dart';
import 'git_runtime_service.dart';
import 'update_service.dart';

class UpdateInstallProgress {
  const UpdateInstallProgress({
    required this.stage,
    required this.message,
    this.percent,
  });

  final String stage;
  final LocalizedMessage message;
  final double? percent;
}

class UpdateInstallResult {
  const UpdateInstallResult.success(this.message) : success = true;
  const UpdateInstallResult.failure(this.message) : success = false;

  final bool success;
  final LocalizedMessage message;
}

class UpdateInstallerService {
  UpdateInstallerService({
    this.storage = const AppStorageService(),
    AppLogService? logService,
    GitRuntimeManager? runtimeManager,
    GitRuntimeInstallationService? runtimeInstallationService,
  }) : logService = logService ?? AppLogService.instance,
       runtimeManager = runtimeManager ?? GitRuntimeManager.instance,
       _runtimeInstallationService =
           runtimeInstallationService ??
           GitRuntimeInstallationService(storage: storage);

  final AppStorageService storage;
  final AppLogService logService;
  final GitRuntimeManager runtimeManager;
  final GitRuntimeInstallationService _runtimeInstallationService;

  Future<UpdateInstallResult> install(
    UpdateCheckResult release, {
    required void Function(UpdateInstallProgress progress) onProgress,
  }) async {
    final validationError = _validateRelease(release);
    if (validationError != null) {
      return UpdateInstallResult.failure(validationError);
    }
    final version = release.latestVersion;
    final updatesRoot = Directory(
      '${storage.dataDirectory.path}${Platform.pathSeparator}updates',
    );
    final archive = File(
      '${updatesRoot.path}${Platform.pathSeparator}'
      'Git_Gui_Expand-v$version.zip',
    );
    try {
      await updatesRoot.create(recursive: true);
      await _deleteFileIfExists(archive);
      onProgress(
        UpdateInstallProgress(
          stage: 'download',
          message: RuntimeMessages.messageFor('updateProgressConnecting'),
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
              message: RuntimeMessages.messageFor(
                'updateProgressDownloading',
                parameters: {'asset': release.assetName},
              ),
              percent: percent,
            ),
          );
        },
      );
      return await _installPreparedArchive(
        release,
        archive,
        onProgress: onProgress,
      );
    } catch (error) {
      logService.errorEvent(
        'update',
        'update.install.failed',
        details: {'error': '$error'},
      );
      return UpdateInstallResult.failure(
        RuntimeMessages.operationFailed(
          error,
          eventId: 'update.install.failed',
        ),
      );
    }
  }

  Future<UpdateInstallResult> installPreparedArchive(
    UpdateCheckResult release,
    File archive, {
    required void Function(UpdateInstallProgress progress) onProgress,
  }) async {
    final validationError = _validateRelease(release);
    if (validationError != null) {
      return UpdateInstallResult.failure(validationError);
    }
    if (!await archive.exists()) {
      return UpdateInstallResult.failure(
        RuntimeMessages.messageFor('updatePackageMissing'),
      );
    }
    try {
      return await _installPreparedArchive(
        release,
        archive,
        onProgress: onProgress,
      );
    } catch (error) {
      logService.errorEvent(
        'update',
        'update.install.preparedArchive.failed',
        details: {'error': '$error'},
      );
      return UpdateInstallResult.failure(
        RuntimeMessages.operationFailed(
          error,
          eventId: 'update.install.preparedArchive.failed',
        ),
      );
    }
  }

  LocalizedMessage? _validateRelease(UpdateCheckResult release) {
    if (!Platform.isWindows) {
      return RuntimeMessages.messageFor('updateWindowsOnly');
    }
    if (release.status != UpdateCheckStatus.updateAvailable) {
      return RuntimeMessages.messageFor('updateNoNewVersion');
    }
    if (release.downloadUrl.isEmpty ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(release.sha256)) {
      return RuntimeMessages.messageFor('updateAssetInvalid');
    }
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(release.latestVersion)) {
      return RuntimeMessages.messageFor('updateVersionInvalid');
    }
    return null;
  }

  Future<UpdateInstallResult> _installPreparedArchive(
    UpdateCheckResult release,
    File archive, {
    required void Function(UpdateInstallProgress progress) onProgress,
  }) async {
    final version = release.latestVersion;
    final updatesRoot = Directory(
      '${storage.dataDirectory.path}${Platform.pathSeparator}updates',
    );
    final versionsRoot = storage.versionsDirectory;
    final staging = Directory(
      '${updatesRoot.path}${Platform.pathSeparator}stage-v$version',
    );
    final target = Directory(
      '${versionsRoot.path}${Platform.pathSeparator}$version',
    );

    try {
      await versionsRoot.create(recursive: true);
      await _deleteDirectoryIfExists(staging);

      onProgress(
        UpdateInstallProgress(
          stage: 'verify',
          message: RuntimeMessages.messageFor('updateProgressVerifying'),
        ),
      );
      final actualHash = await calculateSha256(archive.path);
      if (actualHash.toLowerCase() != release.sha256.toLowerCase()) {
        await _deleteFileIfExists(archive);
        throw const FormatException('更新包 SHA-256 校验失败');
      }
      logService.infoEvent(
        'update',
        'update.package.sha256.verified',
        details: {'sha256': actualHash},
      );

      onProgress(
        UpdateInstallProgress(
          stage: 'extract',
          message: RuntimeMessages.messageFor('updateProgressExtracting'),
        ),
      );
      await staging.create(recursive: true);
      await _extract(archive.path, staging.path);
      final payload = await _resolvePayloadDirectory(staging, version);
      await _validatePayload(payload, version);
      final packagedRuntime = await _readPackagedRuntime(staging);
      if (packagedRuntime != null) {
        onProgress(
          UpdateInstallProgress(
            stage: 'verify',
            message: RuntimeMessages.messageFor(
              'updateProgressVerifyingRuntime',
            ),
          ),
        );
        await runtimeManager.activateRuntime(
          installationService: _runtimeInstallationService,
          runtime: packagedRuntime,
        );
        logService.infoEvent(
          'update',
          'update.runtime.activated',
          details: {'version': packagedRuntime.version},
        );
      } else {
        await _validateInstalledRuntime();
      }

      if (await target.exists()) {
        try {
          await _validatePayload(target, version);
          await _deleteDirectoryIfExists(staging);
        } catch (_) {
          await _deleteDirectoryIfExists(target);
        }
      }

      if (await target.exists()) {
        logService.infoEvent(
          'update',
          'update.version.reused',
          details: {'version': version},
        );
      } else {
        final nestedPayload = payload.path != staging.path;
        await payload.rename(target.path);
        if (nestedPayload && await staging.exists()) {
          await _deleteDirectoryIfExists(staging);
        }
        logService.infoEvent(
          'update',
          'update.version.prepared',
          details: {'version': version, 'path': target.path},
        );
      }
      await _deleteFileIfExists(archive);
      await _deleteDirectoryIfExists(staging);
      logService.detailEvent('update', 'update.package.cleanup.completed');

      onProgress(
        UpdateInstallProgress(
          stage: 'prepare',
          message: RuntimeMessages.messageFor(
            'updateProgressNotifyingLauncher',
          ),
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

      logService.infoEvent(
        'update',
        'update.launcher.ready',
        details: {'version': version},
      );
      return UpdateInstallResult.success(
        RuntimeMessages.messageFor(
          'updateInstallSuccess',
          parameters: {'version': version},
          eventId: 'update.install.succeeded',
          technicalDetails: {'path': target.path},
        ),
      );
    } catch (error) {
      logService.errorEvent(
        'update',
        'update.launcher.prepare.failed',
        details: {'error': '$error', 'version': version},
      );
      return UpdateInstallResult.failure(
        RuntimeMessages.operationFailed(
          error,
          eventId: 'update.launcher.prepare.failed',
          target: version,
        ),
      );
    }
  }

  Future<ValidatedGitRuntime?> _readPackagedRuntime(Directory staging) async {
    final runtimeRoot = Directory(
      '${staging.path}${Platform.pathSeparator}runtime'
      '${Platform.pathSeparator}git',
    );
    final pointer = File(
      '${runtimeRoot.path}${Platform.pathSeparator}current.json',
    );
    if (!await pointer.exists()) return null;
    final decoded = jsonDecode(await pointer.readAsString());
    final activeVersion = decoded is Map<String, dynamic>
        ? (decoded['activeVersion'] as String? ?? '').trim()
        : '';
    if (activeVersion.isEmpty ||
        !RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(activeVersion) ||
        !activeVersion.contains('PortableGit')) {
      throw const FileSystemException('更新包中的 PortableGit current.json 无效');
    }
    return _runtimeInstallationService.validate(
      Directory(
        '${runtimeRoot.path}${Platform.pathSeparator}versions'
        '${Platform.pathSeparator}$activeVersion',
      ),
    );
  }

  Future<void> _validateInstalledRuntime() async {
    final pointerStore = GitRuntimePointerStore(storage: storage);
    final pointer = await pointerStore.read();
    if (!pointer.hasActive) return;
    try {
      await _runtimeInstallationService.validate(
        storage.gitRuntimeVersionDirectory(pointer.activeVersion),
      );
      logService.detailEvent(
        'update',
        'update.runtime.validated',
        details: {'version': pointer.activeVersion},
      );
    } catch (activeError) {
      if (!pointer.hasPrevious) {
        logService.warningEvent(
          'update',
          'update.runtime.invalid.continue',
          details: {'error': '$activeError'},
        );
        return;
      }
      try {
        final restored = await _runtimeInstallationService.restorePrevious();
        logService.warningEvent(
          'update',
          'update.runtime.restored',
          details: {'version': restored.version},
        );
      } catch (restoreError) {
        logService.warningEvent(
          'update',
          'update.runtime.restore.failed',
          details: {'error': '$restoreError'},
        );
      }
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
    final maintenanceLauncher = File(
      '${payload.path}${Platform.pathSeparator}maintenance'
      '${Platform.pathSeparator}GitGuiExpandLauncher.exe',
    );
    if (!await executable.exists() ||
        !await appData.exists() ||
        !await flutterData.exists() ||
        !await maintenanceLauncher.exists()) {
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
      logService.detailEvent(
        'update',
        'update.download.completed',
        details: {
          'path': target.path,
          'received': '$received',
          'expected': '$expected',
        },
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
    await Directory(destination).create(recursive: true);
    final result = await Process.run(
      'tar.exe',
      ['-xf', archivePath, '-C', destination],
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

  Future<String> calculateSha256(String filePath) async {
    final digest = await sha256.bind(File(filePath).openRead()).first;
    return digest.toString();
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
