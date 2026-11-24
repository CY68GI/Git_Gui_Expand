import 'dart:convert';
import 'dart:io';

import '../models/recent_repository.dart';
import 'app_log_service.dart';
import 'app_storage_service.dart';

class RecentRepositoriesService {
  RecentRepositoriesService({
    this.storage = const AppStorageService(),
    AppLogService? logService,
  }) : logService = logService ?? AppLogService.instance;

  static const int maxEntries = 10;

  final AppStorageService storage;
  final AppLogService logService;

  File get _historyFile => File(
    '${storage.dataDirectory.path}${Platform.pathSeparator}'
    'recent_repositories.json',
  );

  Future<List<RecentRepository>> load() async {
    final stored = await _readStored();
    final valid = <RecentRepository>[];
    for (final entry in stored) {
      if (await isValidRepository(entry.path)) {
        valid.add(entry);
      } else {
        logService.detailEvent(
          'history',
          'history.invalid.ignored',
          details: {'path': entry.path},
        );
      }
    }
    final result = _deduplicateAndSort(valid)
        .take(maxEntries)
        .toList(growable: false);
    if (result.length != stored.length) {
      await _write(result);
    }
    logService.detailEvent(
      'history',
      'history.loaded',
      details: {'count': '${result.length}'},
    );
    return result;
  }

  Future<List<RecentRepository>> add(String repositoryRoot) async {
    final normalized = _normalizePath(repositoryRoot);
    if (!await isValidRepository(normalized)) {
      throw const FormatException('该路径不是可用的 Git 仓库根目录');
    }
    final entries = <RecentRepository>[];
    for (final entry in await _readStored()) {
      if (await isValidRepository(entry.path)) {
        entries.add(entry);
      }
    }
    entries.removeWhere((entry) => _samePath(entry.path, normalized));
    entries.insert(
      0,
      RecentRepository(path: normalized, lastOpened: DateTime.now()),
    );
    final result = _deduplicateAndSort(entries).take(maxEntries).toList();
    await _write(result);
    logService.infoEvent(
      'history',
      'history.saved',
      details: {'path': normalized},
    );
    return result;
  }

  Future<List<RecentRepository>> remove(String repositoryPath) async {
    final entries = List<RecentRepository>.of(await _readStored());
    entries.removeWhere((entry) => _samePath(entry.path, repositoryPath));
    final result = _deduplicateAndSort(entries)
        .take(maxEntries)
        .toList(growable: false);
    await _write(result);
    logService.detailEvent(
      'history',
      'history.removed',
      details: {'path': repositoryPath},
    );
    return result;
  }

  Future<bool> isValidRepository(String repositoryRoot) async {
    final path = _normalizePath(repositoryRoot);
    if (!await Directory(path).exists()) return false;
    final gitMetadata = '$path${Platform.pathSeparator}.git';
    final type = await FileSystemEntity.type(gitMetadata, followLinks: false);
    return type == FileSystemEntityType.directory ||
        type == FileSystemEntityType.file;
  }

  Future<List<RecentRepository>> _readStored() async {
    try {
      if (!await _historyFile.exists()) return [];
      final text = await _historyFile.readAsString();
      if (text.trim().isEmpty) return [];
      final decoded = jsonDecode(text);
      final rawEntries = decoded is Map<String, dynamic>
          ? decoded['repositories']
          : decoded;
      if (rawEntries is! List) return [];
      final entries = <RecentRepository>[];
      for (final raw in rawEntries) {
        if (raw is! Map) continue;
        try {
          entries.add(
            RecentRepository.fromJson(Map<String, dynamic>.from(raw)),
          );
        } on FormatException {
          // Ignore a malformed single entry and keep the remaining history.
        }
      }
      return _deduplicateAndSort(entries);
    } catch (error) {
      logService.warningEvent(
        'history',
        'history.read.failed',
        details: {'error': '$error'},
      );
      return [];
    }
  }

  Future<void> _write(List<RecentRepository> entries) async {
    try {
      await storage.ensureDataDirectory();
      final payload = const JsonEncoder.withIndent('  ').convert({
        'version': 1,
        'repositories': entries.map((entry) => entry.toJson()).toList(),
      });
      await _historyFile.writeAsString(payload, flush: true);
    } catch (error) {
      logService.errorEvent(
        'history',
        'history.save.failed',
        details: {'error': '$error'},
      );
      rethrow;
    }
  }

  List<RecentRepository> _deduplicateAndSort(List<RecentRepository> entries) {
    final byPath = <String, RecentRepository>{};
    for (final entry in entries) {
      final key = _pathKey(entry.path);
      final existing = byPath[key];
      if (existing == null || entry.lastOpened.isAfter(existing.lastOpened)) {
        byPath[key] = RecentRepository(
          path: _normalizePath(entry.path),
          lastOpened: entry.lastOpened,
        );
      }
    }
    final result = byPath.values.toList(growable: false)
      ..sort((left, right) => right.lastOpened.compareTo(left.lastOpened));
    return result;
  }

  bool _samePath(String left, String right) =>
      _pathKey(left) == _pathKey(right);

  String _pathKey(String path) {
    final normalized = _normalizePath(path);
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  String _normalizePath(String path) {
    var normalized = Directory(path).absolute.path;
    while (normalized.length > 3 &&
        (normalized.endsWith('\\') || normalized.endsWith('/'))) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
