import 'dart:io';

import 'app_log_service.dart';

typedef ExternalUrlLauncher = Future<void> Function(String url);

class ExternalLinkService {
  ExternalLinkService({AppLogService? logService, this.launcher})
    : _log = logService ?? AppLogService.instance;

  final AppLogService _log;
  final ExternalUrlLauncher? launcher;

  Future<void> openExternalUrl(String url) async {
    _log.detailEvent('browser', 'browser.open', details: {'url': url});
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('只允许打开有效的 HTTPS 链接。');
    }
    final customLauncher = launcher;
    if (customLauncher != null) {
      await customLauncher(url);
      return;
    }

    if (Platform.isWindows) {
      final escaped = url.replaceAll("'", "''");
      final result = await Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        "Start-Process -FilePath '$escaped'",
      ], runInShell: false);
      if (result.exitCode != 0) {
        throw ProcessException(
          'powershell.exe',
          const [],
          '浏览器启动失败，退出码 ${result.exitCode}',
          result.exitCode,
        );
      }
      return;
    }
    if (Platform.isMacOS) {
      await Process.run('open', [url], runInShell: false);
      return;
    }
    if (Platform.isLinux) {
      await Process.run('xdg-open', [url], runInShell: false);
      return;
    }
    throw UnsupportedError('当前平台不支持打开浏览器。');
  }
}
