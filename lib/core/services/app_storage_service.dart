import 'dart:io';

class AppStorageService {
  const AppStorageService({this.softwareDirectoryOverride});

  final String? softwareDirectoryOverride;

  String get softwareDirectory {
    final override = softwareDirectoryOverride;
    if (override != null && override.isNotEmpty) {
      return override;
    }
    final launcherRoot = Platform.environment['GIT_GUI_EXPAND_ROOT'];
    if (launcherRoot != null && launcherRoot.trim().isNotEmpty) {
      return launcherRoot.trim();
    }
    final executableDirectory = File(Platform.resolvedExecutable).parent;
    final versionDirectoryName = _lastPathSegment(executableDirectory.uri);
    final versionsDirectory = executableDirectory.parent;
    if (versionDirectoryName != null &&
        _lastPathSegment(versionsDirectory.uri) == 'versions') {
      return versionsDirectory.parent.path;
    }
    return executableDirectory.path;
  }

  Directory get dataDirectory =>
      Directory('$softwareDirectory${Platform.pathSeparator}userdata');

  Directory get logsDirectory =>
      Directory('${dataDirectory.path}${Platform.pathSeparator}logs');

  File get settingsFile =>
      File('${dataDirectory.path}${Platform.pathSeparator}settings.json');

  bool get isLaunchedByLauncher =>
      Platform.environment['GIT_GUI_EXPAND_LAUNCHED'] == '1';

  Directory get versionsDirectory =>
      Directory('$softwareDirectory${Platform.pathSeparator}versions');

  File get currentVersionFile =>
      File('$softwareDirectory${Platform.pathSeparator}current-version.txt');

  File get pendingVersionFile =>
      File('$softwareDirectory${Platform.pathSeparator}pending-version.txt');

  File get rollbackVersionFile =>
      File('$softwareDirectory${Platform.pathSeparator}rollback-version.txt');

  Future<Directory> ensureDataDirectory() async {
    if (!await dataDirectory.exists()) {
      await dataDirectory.create(recursive: true);
    }
    return dataDirectory;
  }

  Future<Directory> ensureLogsDirectory() async {
    if (!await logsDirectory.exists()) {
      await logsDirectory.create(recursive: true);
    }
    return logsDirectory;
  }

  String? _lastPathSegment(Uri uri) {
    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    return segments.isEmpty ? null : segments.last;
  }
}
