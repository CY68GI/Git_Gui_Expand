import 'dart:io';

import 'package:flutter/widgets.dart';

import '../localization/app_localizations.dart';
import 'app_storage_service.dart';

enum AppLogType { normal, detailed }

class AppLogService {
  AppLogService({this.storage = const AppStorageService()});

  static final AppLogService instance = AppLogService();

  final AppStorageService storage;
  Future<void> _writeQueue = Future<void>.value();
  AppLocalizations _localizations = const AppLocalizations(
    AppLocalizations.simplifiedChinese,
  );

  String get logsDirectoryPath => storage.logsDirectory.path;
  String get languageCode => _localizations.languageCode;

  void setLocale(Locale locale) {
    _localizations = AppLocalizations(AppLocalizations.resolveLocale(locale));
  }

  void info(String area, String message) {
    _enqueue('INFO', area, message, includeInNormal: true);
  }

  void detail(String area, String message) {
    _enqueue('DETAIL', area, message, includeInNormal: false);
  }

  void warning(String area, String message) {
    _enqueue('WARN', area, message, includeInNormal: true);
  }

  void error(String area, String message) {
    _enqueue('ERROR', area, message, includeInNormal: true);
  }

  Future<void> flush() => _writeQueue;

  Future<String> readRecent(
    AppLogType type, {
    int maxCharacters = 180000,
  }) async {
    try {
      final directory = storage.logsDirectory;
      if (!await directory.exists()) {
        return '';
      }
      final prefix = type == AppLogType.normal ? 'normal-' : 'detailed-';
      final files = await directory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .where(
            (file) =>
                file.uri.pathSegments.last.startsWith(prefix) &&
                file.path.toLowerCase().endsWith('.log'),
          )
          .toList();
      files.sort((left, right) => right.path.compareTo(left.path));
      final buffer = StringBuffer();
      for (final file in files.take(5)) {
        final text = await file.readAsString();
        if (text.isEmpty) continue;
        buffer
          ..writeln('===== ${file.uri.pathSegments.last} =====')
          ..writeln(text.trimRight())
          ..writeln();
      }
      final result = buffer.toString();
      if (result.length <= maxCharacters) {
        return result;
      }
      return '… 仅显示最近日志 …\n\n'
          '${result.substring(result.length - maxCharacters)}';
    } catch (error) {
      return '读取日志失败：$error';
    }
  }

  Future<void> openLogsDirectory() async {
    final directory = await storage.ensureLogsDirectory();
    if (Platform.isWindows) {
      await Process.run('explorer.exe', [directory.path], runInShell: false);
      return;
    }
    if (Platform.isMacOS) {
      await Process.run('open', [directory.path], runInShell: false);
      return;
    }
    if (Platform.isLinux) {
      await Process.run('xdg-open', [directory.path], runInShell: false);
    }
  }

  void _enqueue(
    String level,
    String area,
    String message, {
    required bool includeInNormal,
  }) {
    final now = DateTime.now();
    final localizedMessage = _localizations.tr(message);
    final line =
        '${now.toIso8601String()} [$level] [$area] '
        '${_singleLine(localizedMessage)}';
    _writeQueue = _writeQueue
        .then((_) async {
          await storage.ensureLogsDirectory();
          final day = _dayStamp(now);
          if (includeInNormal) {
            await _append(type: AppLogType.normal, day: day, line: line);
          }
          await _append(type: AppLogType.detailed, day: day, line: line);
        })
        .catchError((Object _) {
          // Logging must never interrupt a Git or UI operation.
        });
  }

  Future<void> _append({
    required AppLogType type,
    required String day,
    required String line,
  }) async {
    final prefix = type == AppLogType.normal ? 'normal' : 'detailed';
    final file = File(
      '${storage.logsDirectory.path}${Platform.pathSeparator}'
      '$prefix-$day.log',
    );
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }

  String _dayStamp(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}';
  }

  String _singleLine(String value) {
    final normalized = value.replaceAll('\r\n', '\n');
    return normalized.length <= 30000
        ? normalized
        : '${normalized.substring(0, 30000)}…[truncated]';
  }
}
