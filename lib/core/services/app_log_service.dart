import 'dart:io';

import 'package:flutter/widgets.dart';

import '../localization/app_localizations.dart';
import '../localization/localized_message.dart';
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

  void infoEvent(
    String area,
    String eventId, {
    Map<String, String> details = const {},
  }) {
    event(
      level: AppLogLevel.info,
      area: area,
      message: _eventMessage('logInfo', eventId, details),
    );
  }

  void detailEvent(
    String area,
    String eventId, {
    Map<String, String> details = const {},
  }) {
    event(
      level: AppLogLevel.detail,
      area: area,
      message: _eventMessage('logDetail', eventId, details),
    );
  }

  void warningEvent(
    String area,
    String eventId, {
    Map<String, String> details = const {},
  }) {
    event(
      level: AppLogLevel.warning,
      area: area,
      message: _eventMessage('logWarning', eventId, details),
    );
  }

  void errorEvent(
    String area,
    String eventId, {
    Map<String, String> details = const {},
  }) {
    event(
      level: AppLogLevel.error,
      area: area,
      message: _eventMessage('logError', eventId, details),
    );
  }

  void event({
    required AppLogLevel level,
    required String area,
    required LocalizedMessage message,
  }) {
    final eventId = message.eventId.isEmpty ? area : message.eventId;
    _enqueue(
      level,
      area,
      message,
      eventId: eventId,
      includeInNormal: level != AppLogLevel.detail,
    );
  }

  LocalizedMessage _eventMessage(
    String key,
    String eventId,
    Map<String, String> details,
  ) {
    return LocalizedMessage(
      key: key,
      parameters: {'eventId': eventId},
      eventId: eventId,
      technicalDetails: details,
    );
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
      return '${_localizations.tr('logsTruncated')}\n\n'
          '${result.substring(result.length - maxCharacters)}';
    } catch (error) {
      return _localizations.tr('logReadFailed', {'error': '$error'});
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
    AppLogLevel level,
    String area,
    LocalizedMessage message, {
    required String eventId,
    required bool includeInNormal,
  }) {
    final now = DateTime.now();
    final localizations = _localizations;
    final localizedMessage = message.resolve(localizations);
    final baseLine =
        '${now.toIso8601String()} [${level.label}] [$area] '
        '[$eventId] ${_singleLine(localizedMessage)}';
    final detailLine = message.technicalDetails.isEmpty
        ? baseLine
        : '$baseLine ${_formatDetails(message.technicalDetails)}';
    _writeQueue = _writeQueue
        .then((_) async {
          await storage.ensureLogsDirectory();
          final day = _dayStamp(now);
          if (includeInNormal) {
            await _append(type: AppLogType.normal, day: day, line: baseLine);
          }
          await _append(type: AppLogType.detailed, day: day, line: detailLine);
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

  String _formatDetails(Map<String, String> details) {
    final entries = details.entries.toList(growable: false)
      ..sort((left, right) => left.key.compareTo(right.key));
    return entries
        .map((entry) => '${entry.key}=${_singleLine(entry.value)}')
        .join(' | ');
  }
}

enum AppLogLevel {
  info('INFO'),
  detail('DETAIL'),
  warning('WARN'),
  error('ERROR');

  const AppLogLevel(this.label);

  final String label;
}
