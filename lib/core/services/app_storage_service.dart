import 'dart:io';

class AppStorageService {
  const AppStorageService({
    this.softwareDirectoryOverride,
    this.launcherRootOverride,
    this.executablePathOverride,
    this.launchedByLauncherOverride,
  });

  final String? softwareDirectoryOverride;
  final String? launcherRootOverride;
  final String? executablePathOverride;
  final bool? launchedByLauncherOverride;

  String get softwareDirectory {
    final override = softwareDirectoryOverride;
    if (override != null && override.isNotEmpty) {
      return override;
    }
    final launcherRoot =
        launcherRootOverride ?? Platform.environment['GIT_GUI_EXPAND_ROOT'];
    if (launcherRoot != null && launcherRoot.trim().isNotEmpty) {
      return launcherRoot.trim();
    }
    final executableDirectory = File(
      executablePathOverride ?? Platform.resolvedExecutable,
    ).parent;
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
      launchedByLauncherOverride ??
      Platform.environment['GIT_GUI_EXPAND_LAUNCHED'] == '1';

  Directory get versionsDirectory =>
      Directory('$softwareDirectory${Platform.pathSeparator}versions');

  Directory get runtimeDirectory =>
      Directory('$softwareDirectory${Platform.pathSeparator}runtime');

  Directory get gitRuntimeRoot =>
      Directory('${runtimeDirectory.path}${Platform.pathSeparator}git');

  Directory get gitRuntimeVersionsDirectory =>
      Directory('${gitRuntimeRoot.path}${Platform.pathSeparator}versions');

  Directory get gitRuntimeCurrentDirectory =>
      Directory('${gitRuntimeRoot.path}${Platform.pathSeparator}current');

  File get gitRuntimeCurrentPointerFile =>
      File('${gitRuntimeRoot.path}${Platform.pathSeparator}current.json');

  File get gitRuntimeExecutableFile => File(
    '${gitRuntimeCurrentDirectory.path}${Platform.pathSeparator}cmd'
    '${Platform.pathSeparator}git.exe',
  );

  Directory get gitRuntimeStableCommandDirectory => Directory(
    '${gitRuntimeCurrentDirectory.path}${Platform.pathSeparator}cmd',
  );

  Directory get gitPathBackupDirectory => Directory(
    '${dataDirectory.path}${Platform.pathSeparator}git-path-backups',
  );

  Directory gitRuntimeStageDirectory(String version) => Directory(
    '${dataDirectory.path}${Platform.pathSeparator}updates'
    '${Platform.pathSeparator}git-stage-$version',
  );

  Directory gitRuntimeVersionDirectory(String version) {
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(version)) {
      throw const FormatException(
        'Git runtime version contains unsafe characters.',
      );
    }
    return Directory(
      '${gitRuntimeVersionsDirectory.path}${Platform.pathSeparator}$version',
    );
  }

  File gitRuntimeManifestFile(String version) => File(
    '${gitRuntimeVersionDirectory(version).path}${Platform.pathSeparator}'
    'git-runtime.json',
  );

  File get currentVersionFile =>
      File('$softwareDirectory${Platform.pathSeparator}current-version.txt');

  File get pendingVersionFile =>
      File('$softwareDirectory${Platform.pathSeparator}pending-version.txt');

  File get rollbackVersionFile =>
      File('$softwareDirectory${Platform.pathSeparator}rollback-version.txt');

  File get launcherFile => File(
    '$softwareDirectory${Platform.pathSeparator}GitGuiExpandLauncher.exe',
  );

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
