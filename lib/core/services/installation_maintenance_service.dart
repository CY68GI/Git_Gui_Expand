import 'dart:io';

import 'package:crypto/crypto.dart';

import 'app_log_service.dart';
import 'app_storage_service.dart';
import 'git_runtime_installation_service.dart';

enum MaintenanceItemKind {
  oldVersion,
  updateArchive,
  partialDownload,
  stagingDirectory,
  legacyUpdater,
  legacyFlatFile,
  legacyFlatDirectory,
  obsoleteGitRuntime,
  gitRuntimeArchive,
  gitRuntimeStaging,
}

class MaintenanceItem {
  const MaintenanceItem({
    required this.path,
    required this.kind,
    required this.size,
  });

  final String path;
  final MaintenanceItemKind kind;
  final int size;

  String get name {
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').where((part) => part.isNotEmpty).last;
  }
}

class MaintenanceScanResult {
  const MaintenanceScanResult({
    required this.softwareDirectory,
    required this.currentVersion,
    required this.items,
  });

  final String softwareDirectory;
  final String currentVersion;
  final List<MaintenanceItem> items;

  int get totalBytes => items.fold(0, (total, item) => total + item.size);
}

class MaintenanceCleanupResult {
  const MaintenanceCleanupResult({
    required this.removed,
    required this.failed,
    required this.removedBytes,
  });

  final List<MaintenanceItem> removed;
  final List<MaintenanceItem> failed;
  final int removedBytes;
}

class InstallationMaintenanceService {
  const InstallationMaintenanceService({
    this.storage = const AppStorageService(),
    this.logService,
  });

  final AppStorageService storage;
  final AppLogService? logService;

  AppLogService get _log => logService ?? AppLogService.instance;

  Future<MaintenanceScanResult> scan() async {
    final root = Directory(storage.softwareDirectory).absolute;
    final currentVersion = await _readCurrentVersion();
    final currentVersionDirectory = currentVersion.isEmpty
        ? null
        : Directory(
            '${root.path}${Platform.pathSeparator}versions'
            '${Platform.pathSeparator}$currentVersion',
          );
    final hasVersionedInstall =
        currentVersionDirectory != null &&
        await currentVersionDirectory.exists() &&
        _isSafeVersion(currentVersion);

    final items = <MaintenanceItem>[];
    if (hasVersionedInstall) {
      await _scanVersions(root, currentVersion, items);
      await _scanLegacyFlatPayload(root, items);
    }
    await _scanGitRuntimes(root, items);
    await _scanUpdateArtifacts(root, items);
    items.sort((left, right) => left.path.compareTo(right.path));
    return MaintenanceScanResult(
      softwareDirectory: root.path,
      currentVersion: currentVersion,
      items: List.unmodifiable(items),
    );
  }

  Future<MaintenanceCleanupResult> cleanup(MaintenanceScanResult scan) async {
    final root = Directory(scan.softwareDirectory).absolute.path;
    final versionsRoot = '$root${Platform.pathSeparator}versions';
    final updatesRoot =
        '$root${Platform.pathSeparator}userdata'
        '${Platform.pathSeparator}updates';
    final gitRuntimeVersionsRoot =
        '$root${Platform.pathSeparator}runtime'
        '${Platform.pathSeparator}git'
        '${Platform.pathSeparator}versions';
    final removed = <MaintenanceItem>[];
    final failed = <MaintenanceItem>[];
    var removedBytes = 0;

    for (final item in scan.items) {
      final allowed =
          _isWithin(item.path, versionsRoot) ||
          _isWithin(item.path, updatesRoot) ||
          _isWithin(item.path, gitRuntimeVersionsRoot) ||
          _isRootMaintenancePath(item.path, root);
      if (!allowed) {
        failed.add(item);
        _log.warningEvent(
          'maintenance',
          'maintenance.cleanup.outsideRoot',
          details: {'path': item.path},
        );
        continue;
      }
      try {
        final type = await FileSystemEntity.type(item.path, followLinks: false);
        if (type == FileSystemEntityType.notFound) {
          continue;
        }
        if (type == FileSystemEntityType.directory) {
          await Directory(item.path).delete(recursive: true);
        } else if (type == FileSystemEntityType.file) {
          await File(item.path).delete();
        } else {
          throw FileSystemException('不支持清理的实体类型', item.path);
        }
        removed.add(item);
        removedBytes += item.size;
        _log.infoEvent(
          'maintenance',
          'maintenance.cleanup.item.removed',
          details: {'path': item.path, 'kind': item.kind.name},
        );
      } catch (error) {
        failed.add(item);
        _log.errorEvent(
          'maintenance',
          'maintenance.cleanup.item.failed',
          details: {
            'path': item.path,
            'kind': item.kind.name,
            'error': '$error',
          },
        );
      }
    }
    return MaintenanceCleanupResult(
      removed: List.unmodifiable(removed),
      failed: List.unmodifiable(failed),
      removedBytes: removedBytes,
    );
  }

  Future<void> scheduleLauncherSelfUpdate() async {
    final root = Directory(storage.softwareDirectory).absolute;
    final currentVersion = await _readCurrentVersion();
    if (!_isSafeVersion(currentVersion)) return;
    final source = File(
      '${root.path}${Platform.pathSeparator}versions'
      '${Platform.pathSeparator}$currentVersion'
      '${Platform.pathSeparator}maintenance'
      '${Platform.pathSeparator}GitGuiExpandLauncher.exe',
    );
    final target = storage.launcherFile;
    if (!await source.exists() || !await target.exists()) return;
    if (!await _filesDiffer(source, target)) return;

    final maintenanceDirectory = Directory(
      '${storage.dataDirectory.path}${Platform.pathSeparator}maintenance',
    );
    await maintenanceDirectory.create(recursive: true);
    final helper = File(
      '${maintenanceDirectory.path}${Platform.pathSeparator}'
      'update-launcher.ps1',
    );
    await helper.writeAsString(r'''
$ErrorActionPreference = 'SilentlyContinue'
$source = $env:GIT_GUI_LAUNCHER_SOURCE
$target = $env:GIT_GUI_LAUNCHER_TARGET
$appPid = [int]$env:GIT_GUI_APP_PID
$logPath = $env:GIT_GUI_LAUNCHER_LOG
$sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
Wait-Process -Id $appPid
for ($attempt = 0; $attempt -lt 120; $attempt++) {
  Copy-Item -LiteralPath $source -Destination $target -Force
  $targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
  if ($targetHash -eq $sourceHash) {
    Add-Content -LiteralPath $logPath -Value "$(Get-Date -Format o) Launcher updated"
    exit 0
  }
  Start-Sleep -Milliseconds 500
}
Add-Content -LiteralPath $logPath -Value "$(Get-Date -Format o) Launcher update failed"
''', flush: true);
    await Process.start(
      'powershell.exe',
      [
        '-NoProfile',
        '-WindowStyle',
        'Hidden',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        helper.path,
      ],
      mode: ProcessStartMode.normal,
      environment: {
        'GIT_GUI_LAUNCHER_SOURCE': source.path,
        'GIT_GUI_LAUNCHER_TARGET': target.path,
        'GIT_GUI_APP_PID': pid.toString(),
        'GIT_GUI_LAUNCHER_LOG':
            '${maintenanceDirectory.path}${Platform.pathSeparator}launcher-update.log',
      },
      includeParentEnvironment: true,
      runInShell: false,
    );
    _log.infoEvent('maintenance', 'maintenance.launcher.update.scheduled');
  }

  Future<void> _scanVersions(
    Directory root,
    String currentVersion,
    List<MaintenanceItem> items,
  ) async {
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}versions',
    );
    if (!await directory.exists()) return;
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! Directory) continue;
      if (await FileSystemEntity.isLink(entity.path)) continue;
      final name = _lastSegment(entity.path);
      if (name == currentVersion) continue;
      items.add(
        MaintenanceItem(
          path: entity.path,
          kind: MaintenanceItemKind.oldVersion,
          size: await _sizeOf(entity),
        ),
      );
    }
  }

  Future<void> _scanLegacyFlatPayload(
    Directory root,
    List<MaintenanceItem> items,
  ) async {
    final legacyFiles = [
      'git_gui_expand.exe',
      'flutter_windows.dll',
      'version.json',
      'native_assets.json',
    ];
    for (final name in legacyFiles) {
      final file = File('${root.path}${Platform.pathSeparator}$name');
      if (await file.exists()) {
        items.add(
          MaintenanceItem(
            path: file.path,
            kind: MaintenanceItemKind.legacyFlatFile,
            size: await file.length(),
          ),
        );
      }
    }
    final data = Directory('${root.path}${Platform.pathSeparator}data');
    if (await data.exists()) {
      items.add(
        MaintenanceItem(
          path: data.path,
          kind: MaintenanceItemKind.legacyFlatDirectory,
          size: await _sizeOf(data),
        ),
      );
    }
  }

  Future<void> _scanUpdateArtifacts(
    Directory root,
    List<MaintenanceItem> items,
  ) async {
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}userdata'
      '${Platform.pathSeparator}updates',
    );
    if (!await directory.exists()) return;
    await for (final entity in directory.list(followLinks: false)) {
      if (await FileSystemEntity.isLink(entity.path)) continue;
      final name = _lastSegment(entity.path).toLowerCase();
      MaintenanceItemKind? kind;
      if (entity is Directory && name.startsWith('stage-v')) {
        kind = MaintenanceItemKind.stagingDirectory;
      } else if (entity is Directory && name.startsWith('git-stage-')) {
        kind = MaintenanceItemKind.gitRuntimeStaging;
      } else if (entity is File &&
          name.startsWith('git_gui_expand-') &&
          name.endsWith('.zip')) {
        kind = MaintenanceItemKind.updateArchive;
      } else if (entity is File &&
          name.contains('portablegit') &&
          name.endsWith('.zip')) {
        kind = MaintenanceItemKind.gitRuntimeArchive;
      } else if (entity is File &&
          name.startsWith('git_gui_expand-') &&
          (name.endsWith('.sha256') || name.endsWith('.sha256sum'))) {
        kind = MaintenanceItemKind.updateArchive;
      } else if (entity is File && name.endsWith('.part')) {
        kind = MaintenanceItemKind.partialDownload;
      } else if (entity is File && name == 'apply-update.ps1') {
        kind = MaintenanceItemKind.legacyUpdater;
      }
      if (kind == null) continue;
      items.add(
        MaintenanceItem(
          path: entity.path,
          kind: kind,
          size: entity is File
              ? await entity.length()
              : await _sizeOf(entity as Directory),
        ),
      );
    }
  }

  Future<void> _scanGitRuntimes(
    Directory root,
    List<MaintenanceItem> items,
  ) async {
    final versions = Directory(
      '${root.path}${Platform.pathSeparator}runtime'
      '${Platform.pathSeparator}git'
      '${Platform.pathSeparator}versions',
    );
    if (!await versions.exists()) return;
    final pointer = await GitRuntimePointerStore(storage: storage).read();
    final retained = {
      if (pointer.activeVersion.isNotEmpty) pointer.activeVersion,
      if (pointer.previousVersion.isNotEmpty) pointer.previousVersion,
    };
    await for (final entity in versions.list(followLinks: false)) {
      if (entity is! Directory) continue;
      if (await FileSystemEntity.isLink(entity.path)) continue;
      final name = _lastSegment(entity.path);
      if (retained.contains(name)) continue;
      items.add(
        MaintenanceItem(
          path: entity.path,
          kind: MaintenanceItemKind.obsoleteGitRuntime,
          size: await _sizeOf(entity),
        ),
      );
    }
  }

  Future<String> _readCurrentVersion() async {
    try {
      if (await storage.currentVersionFile.exists()) {
        return (await storage.currentVersionFile.readAsString()).trim();
      }
    } catch (_) {
      return '';
    }
    return '';
  }

  bool _isSafeVersion(String value) {
    return value.isNotEmpty &&
        value.length <= 64 &&
        RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(value);
  }

  String _lastSegment(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').where((part) => part.isNotEmpty).last;
  }

  bool _isWithin(String path, String directory) {
    final normalizedPath = File(path).absolute.path.toLowerCase();
    final normalizedDirectory =
        '${Directory(directory).absolute.path.toLowerCase()}\\';
    return normalizedPath.startsWith(normalizedDirectory);
  }

  bool _isRootMaintenancePath(String path, String root) {
    final name = _lastSegment(path).toLowerCase();
    return const {
          'git_gui_expand.exe',
          'flutter_windows.dll',
          'version.json',
          'native_assets.json',
          'data',
        }.contains(name) &&
        File(path).parent.absolute.path.toLowerCase() ==
            Directory(root).absolute.path.toLowerCase();
  }

  Future<int> _sizeOf(Directory directory) async {
    var total = 0;
    try {
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return total;
  }

  Future<bool> _filesDiffer(File left, File right) async {
    if (await left.length() != await right.length()) return true;
    final leftDigest = await sha256.bind(left.openRead()).first;
    final rightDigest = await sha256.bind(right.openRead()).first;
    return leftDigest != rightDigest;
  }
}
