import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../utils/path_utils.dart';
import 'app_log_service.dart';
import 'app_storage_service.dart';
import 'git_runtime_installation_service.dart';

enum GitRuntimeSource { system, bundled }

@immutable
class GitRuntimeStatus {
  const GitRuntimeStatus._({
    required this.isChecking,
    required this.source,
    required this.executablePath,
    required this.version,
    required this.checkedAt,
    required this.error,
  });

  const GitRuntimeStatus.unknown()
    : this._(
        isChecking: false,
        source: null,
        executablePath: '',
        version: '',
        checkedAt: null,
        error: null,
      );

  const GitRuntimeStatus.checking(DateTime checkedAt)
    : this._(
        isChecking: true,
        source: null,
        executablePath: '',
        version: '',
        checkedAt: checkedAt,
        error: null,
      );

  const GitRuntimeStatus.available({
    required GitRuntimeSource source,
    required String executablePath,
    required String version,
    required DateTime checkedAt,
  }) : this._(
         isChecking: false,
         source: source,
         executablePath: executablePath,
         version: version,
         checkedAt: checkedAt,
         error: null,
       );

  const GitRuntimeStatus.unavailable({
    required DateTime checkedAt,
    String? error,
  }) : this._(
         isChecking: false,
         source: null,
         executablePath: '',
         version: '',
         checkedAt: checkedAt,
         error: error,
       );

  final bool isChecking;
  final GitRuntimeSource? source;
  final String executablePath;
  final String version;
  final DateTime? checkedAt;
  final String? error;

  bool get isAvailable => source != null && executablePath.isNotEmpty;
  bool get isBundled => source == GitRuntimeSource.bundled;
}

typedef GitCandidateProvider = Future<List<String>> Function();
typedef GitVersionProbe = Future<String?> Function(String executablePath);

class GitRuntimeDiscovery {
  GitRuntimeDiscovery({
    this.storage = const AppStorageService(),
    GitCandidateProvider? candidateProvider,
    GitVersionProbe? versionProbe,
    this.bundledExecutableOverride,
    GitRuntimePointerStore? pointerStore,
    GitRuntimeInstallationService? installationService,
  }) : _candidateProvider = candidateProvider ?? _defaultCandidates,
       _versionProbe = versionProbe ?? _defaultVersionProbe,
       _pointerStore = pointerStore ?? GitRuntimePointerStore(storage: storage),
       _installationService =
           installationService ??
           GitRuntimeInstallationService(storage: storage);

  final AppStorageService storage;
  final GitCandidateProvider _candidateProvider;
  final GitVersionProbe _versionProbe;
  final String? bundledExecutableOverride;
  final GitRuntimePointerStore _pointerStore;
  final GitRuntimeInstallationService _installationService;

  Future<GitRuntimeStatus> discover() async {
    final checkedAt = DateTime.now().toUtc();
    final failures = <String>[];
    List<String> candidates;
    try {
      candidates = await _candidateProvider();
    } catch (error) {
      failures.add('PATH candidates: $error');
      candidates = const [];
    }

    final seen = <String>{};
    for (final rawPath in candidates) {
      final path = File(rawPath).absolute.path;
      final normalized = _normalizedPath(path);
      if (!seen.add(normalized) || _isWithinApplicationRuntime(path)) {
        continue;
      }
      final version = await _validateCandidate(path, failures);
      if (version != null) {
        return GitRuntimeStatus.available(
          source: GitRuntimeSource.system,
          executablePath: path,
          version: version,
          checkedAt: checkedAt,
        );
      }
    }

    final pointer = await _pointerStore.read();
    if (pointer.hasActive && bundledExecutableOverride == null) {
      try {
        final validated = await _installationService.validate(
          storage.gitRuntimeVersionDirectory(pointer.activeVersion),
        );
        return GitRuntimeStatus.available(
          source: GitRuntimeSource.bundled,
          executablePath: validated.executable.path,
          version: validated.manifest.gitVersion,
          checkedAt: checkedAt,
        );
      } catch (error) {
        failures.add('active runtime ${pointer.activeVersion}: $error');
        if (pointer.hasPrevious) {
          try {
            final restored = await _installationService.restorePrevious();
            return GitRuntimeStatus.available(
              source: GitRuntimeSource.bundled,
              executablePath: restored.executable.path,
              version: restored.manifest.gitVersion,
              checkedAt: checkedAt,
            );
          } catch (fallbackError) {
            failures.add(
              'previous runtime ${pointer.previousVersion}: $fallbackError',
            );
          }
        }
      }
    } else {
      final bundledPath = File(
        bundledExecutableOverride ?? storage.gitRuntimeExecutableFile.path,
      ).absolute.path;
      final bundledVersion = await _validateCandidate(bundledPath, failures);
      if (bundledVersion != null) {
        return GitRuntimeStatus.available(
          source: GitRuntimeSource.bundled,
          executablePath: bundledPath,
          version: bundledVersion,
          checkedAt: checkedAt,
        );
      }
    }

    return GitRuntimeStatus.unavailable(
      checkedAt: checkedAt,
      error: failures.isEmpty
          ? 'No Git executable was found.'
          : 'No Git executable was found.\n${failures.join('\n')}',
    );
  }

  bool _isWithinApplicationRuntime(String executablePath) {
    final runtimeRoot = _normalizedPath(storage.gitRuntimeRoot.path);
    final candidate = _normalizedPath(File(executablePath).absolute.path);
    return candidate == runtimeRoot ||
        candidate.startsWith('${toPosixPath(runtimeRoot)}/');
  }

  Future<String?> _validateCandidate(
    String executablePath,
    List<String> failures,
  ) async {
    try {
      final version = await _versionProbe(executablePath);
      if (version != null && version.trim().isNotEmpty) {
        return version.trim();
      }
      failures.add('$executablePath: version probe returned no version');
    } catch (error) {
      failures.add('$executablePath: $error');
    }
    return null;
  }

  static Future<List<String>> _defaultCandidates() async {
    if (Platform.isWindows) {
      final result = await Process.run(
        'where.exe',
        const ['git'],
        runInShell: false,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      final fromWhere = (result.stdout as String? ?? '')
          .split(RegExp(r'[\r\n]+'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: true);
      if (fromWhere.isNotEmpty) return fromWhere;
    }

    final pathValue = Platform.environment['PATH'] ?? '';
    final separator = Platform.isWindows ? ';' : ':';
    final executableName = Platform.isWindows ? 'git.exe' : 'git';
    return pathValue
        .split(separator)
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .map((entry) => '$entry${Platform.pathSeparator}$executableName')
        .toList(growable: false);
  }

  static Future<String?> _defaultVersionProbe(String executablePath) async {
    final result = await Process.run(
      executablePath,
      const ['--version'],
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(const Duration(seconds: 5));
    if (result.exitCode != 0) return null;
    final output = '${result.stdout ?? ''}\n${result.stderr ?? ''}';
    final match = RegExp(
      r'git version\s+([^\s]+)',
      caseSensitive: false,
    ).firstMatch(output);
    return match?.group(1);
  }

  String _normalizedPath(String path) =>
      toPosixPath(File(path).absolute.path).toLowerCase();
}

class GitRuntimeManager extends ChangeNotifier {
  GitRuntimeManager({
    GitRuntimeDiscovery? discovery,
    AppLogService? logService,
    GitRuntimeStatus initialStatus = const GitRuntimeStatus.unknown(),
  }) : _discovery = discovery ?? GitRuntimeDiscovery(),
       _log = logService ?? AppLogService.instance,
       _status = initialStatus;

  static final GitRuntimeManager instance = GitRuntimeManager();

  final GitRuntimeDiscovery _discovery;
  final AppLogService _log;
  GitRuntimeStatus _status;
  Future<GitRuntimeStatus>? _refreshFuture;
  int _activeCommands = 0;

  GitRuntimeStatus get status => _status;
  int get activeCommandCount => _activeCommands;
  bool get hasActiveCommands => _activeCommands > 0;

  Future<GitRuntimeStatus> refresh() {
    final active = _refreshFuture;
    if (active != null) return active;

    final future = _refresh();
    _refreshFuture = future;
    return future.whenComplete(() {
      if (identical(_refreshFuture, future)) {
        _refreshFuture = null;
      }
    });
  }

  Future<GitRuntimeStatus> _refresh() async {
    _status = GitRuntimeStatus.checking(DateTime.now().toUtc());
    notifyListeners();
    try {
      final next = await _discovery.discover();
      _status = next;
      if (next.isAvailable) {
        _log.infoEvent(
          'git',
          'git.runtime.available',
          details: {
            'source': next.source!.name,
            'version': next.version,
            'path': next.executablePath,
          },
        );
      } else {
        _log.warningEvent(
          'git',
          'git.runtime.unavailable',
          details: {'error': next.error ?? ''},
        );
      }
      notifyListeners();
      return next;
    } catch (error) {
      _status = GitRuntimeStatus.unavailable(
        checkedAt: DateTime.now().toUtc(),
        error: error.toString(),
      );
      _log.errorEvent(
        'git',
        'git.runtime.detection.failed',
        details: {'error': '$error'},
      );
      notifyListeners();
      return _status;
    }
  }

  Future<String> requireExecutablePath() async {
    var current = _status;
    if (!current.isAvailable && !current.isChecking) {
      current = await refresh();
    } else if (current.isChecking) {
      current = await (_refreshFuture ?? refresh());
    }
    if (!current.isAvailable) {
      throw StateError(
        current.error?.trim().isNotEmpty == true
            ? '未检测到可用 Git：${current.error}'
            : '未检测到可用 Git。',
      );
    }
    return current.executablePath;
  }

  Future<T> runWithCommandTracking<T>(Future<T> Function() action) async {
    _activeCommands++;
    try {
      return await action();
    } finally {
      _activeCommands--;
    }
  }

  Future<void> waitUntilIdle({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (_activeCommands > 0) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('Git commands are still running.', timeout);
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<ValidatedGitRuntime> activateRuntime({
    required GitRuntimeInstallationService installationService,
    required ValidatedGitRuntime runtime,
    Duration idleTimeout = const Duration(seconds: 30),
  }) async {
    await waitUntilIdle(timeout: idleTimeout);
    final validated = await installationService.activate(runtime);
    await refresh();
    return validated;
  }
}
