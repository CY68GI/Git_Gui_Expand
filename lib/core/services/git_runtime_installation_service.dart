import 'dart:convert';
import 'dart:io';

import '../utils/path_utils.dart';
import 'app_storage_service.dart';

class GitRuntimeManifest {
  const GitRuntimeManifest({
    required this.runtimeFormat,
    required this.packageName,
    required this.gitVersion,
    required this.sourceUrl,
    required this.archiveSha256,
    required this.licensePath,
    required this.noticePath,
    required this.builtAt,
  });

  final int runtimeFormat;
  final String packageName;
  final String gitVersion;
  final String sourceUrl;
  final String archiveSha256;
  final String licensePath;
  final String noticePath;
  final String builtAt;

  factory GitRuntimeManifest.fromJson(Map<String, dynamic> json) {
    return GitRuntimeManifest(
      runtimeFormat: (json['runtimeFormat'] as num?)?.toInt() ?? 0,
      packageName: json['packageName'] as String? ?? '',
      gitVersion: json['gitVersion'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      archiveSha256: json['archiveSha256'] as String? ?? '',
      licensePath: json['licensePath'] as String? ?? '',
      noticePath: json['noticePath'] as String? ?? '',
      builtAt: json['builtAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'runtimeFormat': runtimeFormat,
    'packageName': packageName,
    'gitVersion': gitVersion,
    'sourceUrl': sourceUrl,
    'archiveSha256': archiveSha256,
    'licensePath': licensePath,
    'noticePath': noticePath,
    'builtAt': builtAt,
  };
}

class GitRuntimeSmokeResult {
  const GitRuntimeSmokeResult({required this.version, required this.execPath});

  final String version;
  final String execPath;
}

class ValidatedGitRuntime {
  const ValidatedGitRuntime({
    required this.directory,
    required this.executable,
    required this.manifest,
    required this.smokeResult,
  });

  final Directory directory;
  final File executable;
  final GitRuntimeManifest manifest;
  final GitRuntimeSmokeResult smokeResult;

  String get version => manifest.packageName;
}

class GitRuntimeValidationException implements Exception {
  const GitRuntimeValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

typedef GitRuntimeSmokeProbe = Future<GitRuntimeSmokeResult> Function(
  String executablePath,
);

class GitRuntimePointer {
  const GitRuntimePointer({
    required this.activeVersion,
    required this.activePath,
    required this.previousVersion,
    required this.previousPath,
    required this.activatedAt,
  });

  const GitRuntimePointer.empty()
    : activeVersion = '',
      activePath = '',
      previousVersion = '',
      previousPath = '',
      activatedAt = null;

  final String activeVersion;
  final String activePath;
  final String previousVersion;
  final String previousPath;
  final DateTime? activatedAt;

  bool get hasActive => activeVersion.isNotEmpty && activePath.isNotEmpty;
  bool get hasPrevious => previousVersion.isNotEmpty && previousPath.isNotEmpty;

  factory GitRuntimePointer.fromJson(Map<String, dynamic> json) {
    return GitRuntimePointer(
      activeVersion: json['activeVersion'] as String? ?? '',
      activePath: json['activePath'] as String? ?? '',
      previousVersion: json['previousVersion'] as String? ?? '',
      previousPath: json['previousPath'] as String? ?? '',
      activatedAt: DateTime.tryParse(json['activatedAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'runtimeFormat': 1,
    'activeVersion': activeVersion,
    'activePath': activePath,
    'previousVersion': previousVersion,
    'previousPath': previousPath,
    'activatedAt': activatedAt?.toUtc().toIso8601String(),
  };
}

typedef GitRuntimePointerCommitter = Future<void> Function(
  File temporary,
  File target,
);

class GitRuntimePointerStore {
  GitRuntimePointerStore({
    this.storage = const AppStorageService(),
    GitRuntimePointerCommitter? committer,
  }) : _committer = committer ?? _defaultCommitter;

  final AppStorageService storage;
  final GitRuntimePointerCommitter _committer;

  Future<GitRuntimePointer> read() async {
    final file = storage.gitRuntimeCurrentPointerFile;
    if (!await file.exists()) return const GitRuntimePointer.empty();
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return const GitRuntimePointer.empty();
      }
      final pointer = GitRuntimePointer.fromJson(decoded);
      if (pointer.hasActive && !_isSafeVersion(pointer.activeVersion)) {
        return const GitRuntimePointer.empty();
      }
      if (pointer.hasPrevious && !_isSafeVersion(pointer.previousVersion)) {
        return GitRuntimePointer(
          activeVersion: pointer.activeVersion,
          activePath: pointer.activePath,
          previousVersion: '',
          previousPath: '',
          activatedAt: pointer.activatedAt,
        );
      }
      return pointer;
    } catch (_) {
      return const GitRuntimePointer.empty();
    }
  }

  Future<void> write(GitRuntimePointer pointer) async {
    await storage.gitRuntimeRoot.create(recursive: true);
    final target = storage.gitRuntimeCurrentPointerFile;
    final temporary = File('${target.path}.tmp');
    final json = const JsonEncoder.withIndent('  ').convert(pointer.toJson());
    await temporary.writeAsString('$json\n', flush: true);
    try {
      await _committer(temporary, target);
    } catch (_) {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
  }

  bool _isSafeVersion(String value) =>
      value.length <= 128 && RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(value);

  static Future<void> _defaultCommitter(File temporary, File target) async {
    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
  }
}

typedef GitRuntimeStableLinkUpdater = Future<void> Function(
  Directory link,
  Directory target,
);

class GitRuntimeInstallationService {
  GitRuntimeInstallationService({
    this.storage = const AppStorageService(),
    this.smokeProbe,
    GitRuntimePointerStore? pointerStore,
    GitRuntimeStableLinkUpdater? stableLinkUpdater,
  }) : _pointerStore = pointerStore ?? GitRuntimePointerStore(storage: storage),
       _stableLinkUpdater = stableLinkUpdater ?? _defaultStableLinkUpdater;

  final AppStorageService storage;
  final GitRuntimeSmokeProbe? smokeProbe;
  final GitRuntimePointerStore _pointerStore;
  final GitRuntimeStableLinkUpdater _stableLinkUpdater;

  Future<GitRuntimePointer> readPointer() => _pointerStore.read();

  Future<ValidatedGitRuntime> activate(
    ValidatedGitRuntime runtime, {
    Future<void> Function()? waitUntilIdle,
  }) async {
    await waitUntilIdle?.call();
    final version = runtime.version;
    final target = storage.gitRuntimeVersionDirectory(version);
    var validated = runtime;
    if (runtime.directory.absolute.path != target.absolute.path) {
      await storage.gitRuntimeVersionsDirectory.create(recursive: true);
      if (await target.exists()) {
        validated = await validate(target);
      } else {
        try {
          await runtime.directory.rename(target.path);
        } on FileSystemException {
          await _copyDirectory(runtime.directory, target);
          await runtime.directory.delete(recursive: true);
        }
        validated = await validate(target);
      }
    }

    final previous = await _pointerStore.read();
    final next = GitRuntimePointer(
      activeVersion: version,
      activePath: 'versions/$version',
      previousVersion: previous.hasActive && previous.activeVersion != version
          ? previous.activeVersion
          : previous.previousVersion,
      previousPath: previous.hasActive && previous.activeVersion != version
          ? previous.activePath
          : previous.previousPath,
      activatedAt: DateTime.now().toUtc(),
    );
    await _stableLinkUpdater(
      storage.gitRuntimeCurrentDirectory,
      validated.directory,
    );
    try {
      await _pointerStore.write(next);
    } catch (_) {
      if (previous.hasActive) {
        await _stableLinkUpdater(
          storage.gitRuntimeCurrentDirectory,
          storage.gitRuntimeVersionDirectory(previous.activeVersion),
        );
      }
      rethrow;
    }
    return validated;
  }

  Future<ValidatedGitRuntime> restorePrevious() async {
    final pointer = await _pointerStore.read();
    if (!pointer.hasPrevious) {
      throw const GitRuntimeValidationException(
        'No previous PortableGit runtime is available.',
      );
    }
    final validated = await validate(
      storage.gitRuntimeVersionDirectory(pointer.previousVersion),
    );
    await _stableLinkUpdater(
      storage.gitRuntimeCurrentDirectory,
      validated.directory,
    );
    await _pointerStore.write(
      GitRuntimePointer(
        activeVersion: validated.version,
        activePath: 'versions/${validated.version}',
        previousVersion: '',
        previousPath: '',
        activatedAt: DateTime.now().toUtc(),
      ),
    );
    return validated;
  }

  Future<ValidatedGitRuntime> validate(Directory versionDirectory) async {
    final directory = Directory(versionDirectory.absolute.path);
    if (!await directory.exists()) {
      throw const GitRuntimeValidationException(
        'PortableGit runtime directory does not exist.',
      );
    }
    final packageName = repositoryBasename(directory.path);
    if (!packageName.contains('PortableGit')) {
      throw const GitRuntimeValidationException(
        'PortableGit runtime directory name must contain PortableGit.',
      );
    }

    final executable = File(
      '${directory.path}${Platform.pathSeparator}cmd'
      '${Platform.pathSeparator}git.exe',
    );
    if (!await executable.exists()) {
      throw const GitRuntimeValidationException(
        'PortableGit runtime is missing cmd/git.exe.',
      );
    }
    if (!await Directory('${directory.path}${Platform.pathSeparator}usr')
            .exists() ||
        (!await Directory('${directory.path}${Platform.pathSeparator}mingw64')
                .exists() &&
            !await Directory('${directory.path}${Platform.pathSeparator}ucrt64')
                .exists())) {
      throw const GitRuntimeValidationException(
        'PortableGit runtime is missing usr and mingw64/ucrt64.',
      );
    }

    final manifestFile = File(
      '${directory.path}${Platform.pathSeparator}git-runtime.json',
    );
    if (!await manifestFile.exists()) {
      throw const GitRuntimeValidationException(
        'PortableGit runtime is missing git-runtime.json.',
      );
    }
    final manifest = _parseManifest(await manifestFile.readAsString());
    if (manifest.runtimeFormat != 1) {
      throw const GitRuntimeValidationException(
        'Unsupported PortableGit runtime manifest format.',
      );
    }
    if (manifest.packageName != packageName) {
      throw const GitRuntimeValidationException(
        'PortableGit directory and manifest package names differ.',
      );
    }
    if (manifest.gitVersion.trim().isEmpty ||
        !RegExp(r'^\d+(?:\.\d+)+').hasMatch(manifest.gitVersion)) {
      throw const GitRuntimeValidationException(
        'PortableGit manifest has an invalid Git version.',
      );
    }
    if (!RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(manifest.archiveSha256)) {
      throw const GitRuntimeValidationException(
        'PortableGit manifest has an invalid archive SHA-256.',
      );
    }
    if (!Uri.tryParse(manifest.sourceUrl)!.hasScheme ||
        !manifest.sourceUrl.startsWith('https://')) {
      throw const GitRuntimeValidationException(
        'PortableGit manifest source URL must use HTTPS.',
      );
    }
    for (final relativePath in [manifest.licensePath, manifest.noticePath]) {
      final normalized = normalizeRepositoryPath(relativePath);
      if (normalized.isEmpty ||
          normalized.startsWith('../') ||
          normalized == '..' ||
          !await File(
            '${directory.path}${Platform.pathSeparator}'
            '${normalized.replaceAll('/', Platform.pathSeparator)}',
          ).exists()) {
        throw GitRuntimeValidationException(
          'PortableGit runtime is missing required notice: $relativePath',
        );
      }
    }

    final smokeResult = await (smokeProbe ?? _defaultSmokeProbe)(
      executable.path,
    );
    if (smokeResult.version.trim() != manifest.gitVersion.trim()) {
      throw GitRuntimeValidationException(
        'PortableGit version mismatch: manifest ${manifest.gitVersion}, '
        'executable ${smokeResult.version}.',
      );
    }
    final canonicalRuntime = _normalizePath(directory.path);
    final canonicalExecPath = _normalizePath(smokeResult.execPath);
    if (!canonicalExecPath.startsWith('$canonicalRuntime/') &&
        canonicalExecPath != canonicalRuntime) {
      throw const GitRuntimeValidationException(
        'PortableGit exec-path is outside the bundled runtime.',
      );
    }
    return ValidatedGitRuntime(
      directory: directory,
      executable: executable,
      manifest: manifest,
      smokeResult: smokeResult,
    );
  }

  GitRuntimeManifest _parseManifest(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('manifest must be a JSON object');
      }
      return GitRuntimeManifest.fromJson(decoded);
    } catch (error) {
      throw GitRuntimeValidationException(
        'PortableGit manifest is malformed: $error',
      );
    }
  }

  static Future<GitRuntimeSmokeResult> _defaultSmokeProbe(
    String executablePath,
  ) async {
    final versionResult = await Process.run(
      executablePath,
      const ['--version'],
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(const Duration(seconds: 8));
    if (versionResult.exitCode != 0) {
      throw const GitRuntimeValidationException(
        'PortableGit version probe failed.',
      );
    }
    final versionMatch = RegExp(r'git version\s+([^\s]+)', caseSensitive: false)
        .firstMatch(
          '${versionResult.stdout ?? ''}\n${versionResult.stderr ?? ''}',
        );
    if (versionMatch == null) {
      throw const GitRuntimeValidationException(
        'PortableGit returned an unrecognized version.',
      );
    }
    final execPathResult = await Process.run(
      executablePath,
      const ['--exec-path'],
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(const Duration(seconds: 8));
    if (execPathResult.exitCode != 0) {
      throw const GitRuntimeValidationException(
        'PortableGit exec-path smoke test failed.',
      );
    }
    return GitRuntimeSmokeResult(
      version: versionMatch.group(1)!,
      execPath: (execPathResult.stdout as String? ?? '').trim(),
    );
  }

  Future<void> _copyDirectory(Directory source, Directory target) async {
    await target.create(recursive: true);
    await for (final entity in source.list(
      recursive: true,
      followLinks: false,
    )) {
      final relative = entity.path.substring(source.path.length);
      final destination = '${target.path}$relative';
      if (entity is Directory) {
        await Directory(destination).create(recursive: true);
      } else if (entity is File) {
        await File(entity.path).copy(destination);
      } else {
        throw GitRuntimeValidationException(
          'Unsupported PortableGit runtime entry: ${entity.path}',
        );
      }
    }
  }

  static Future<void> _defaultStableLinkUpdater(
    Directory link,
    Directory target,
  ) async {
    await link.parent.create(recursive: true);
    if (await FileSystemEntity.isLink(link.path)) {
      if (Platform.isWindows) {
        final remove = await Process.run('cmd.exe', [
          '/d',
          '/c',
          'rmdir',
          link.path,
        ], runInShell: false);
        if (remove.exitCode != 0) {
          throw GitRuntimeValidationException(
            'Could not remove the existing PortableGit runtime link.',
          );
        }
      } else {
        await Link(link.path).delete();
      }
    } else if (await link.exists()) {
      throw GitRuntimeValidationException(
        'Refusing to replace a non-link runtime path: ${link.path}',
      );
    }

    if (Platform.isWindows) {
      final result = await Process.run('cmd.exe', [
        '/d',
        '/c',
        'mklink',
        '/J',
        link.path,
        target.path,
      ], runInShell: false);
      if (result.exitCode != 0) {
        throw GitRuntimeValidationException(
          'Could not create the PortableGit runtime junction: '
          '${result.stderr}',
        );
      }
      return;
    }
    await Link(link.path).create(target.path);
  }

  String _normalizePath(String path) =>
      toPosixPath(File(path).absolute.path).toLowerCase();
}
