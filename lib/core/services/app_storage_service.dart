import 'dart:io';

class AppStorageService {
  const AppStorageService({this.softwareDirectoryOverride});

  final String? softwareDirectoryOverride;

  String get softwareDirectory {
    final override = softwareDirectoryOverride;
    if (override != null && override.isNotEmpty) {
      return override;
    }
    return File(Platform.resolvedExecutable).parent.path;
  }

  Directory get dataDirectory =>
      Directory('$softwareDirectory${Platform.pathSeparator}userdata');

  Directory get logsDirectory =>
      Directory('${dataDirectory.path}${Platform.pathSeparator}logs');

  File get settingsFile =>
      File('${dataDirectory.path}${Platform.pathSeparator}settings.json');

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
}
