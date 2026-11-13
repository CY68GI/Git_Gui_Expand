import 'dart:convert';
import 'dart:io';

import 'app_log_service.dart';

class FontCatalogService {
  FontCatalogService({AppLogService? logService})
    : logService = logService ?? AppLogService.instance;

  final AppLogService logService;

  Future<List<String>> loadInstalledFonts() async {
    final fonts = <String>{..._platformFallbacks()};
    try {
      if (Platform.isWindows) {
        final result = await Process.run(
          'powershell.exe',
          [
            '-NoProfile',
            '-NonInteractive',
            '-Command',
            '''
Add-Type -AssemblyName System.Drawing
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding(\$false)
\$collection = New-Object System.Drawing.Text.InstalledFontCollection
\$collection.Families | ForEach-Object { \$_.Name }
''',
          ],
          runInShell: false,
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );
        if (result.exitCode == 0) {
          fonts.addAll(_parseLines(result.stdout as String));
        }
      } else {
        final result = await Process.run(
          'fc-list',
          ['-f', '%{family[0]}\\n'],
          runInShell: false,
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );
        if (result.exitCode == 0) {
          fonts.addAll(_parseLines(result.stdout as String));
        }
      }
    } catch (error) {
      logService.warning('font', '读取系统字体失败，使用跨平台推荐列表：$error');
    }

    final result =
        fonts
            .map((font) => font.trim())
            .where((font) => font.isNotEmpty && !font.startsWith('@'))
            .toSet()
            .toList(growable: false)
          ..sort(
            (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
          );
    logService.detail('font', '已读取 ${result.length} 个可用字体');
    return result;
  }

  List<String> _platformFallbacks() {
    if (Platform.isWindows) {
      return const [
        'Segoe UI',
        'Microsoft YaHei UI',
        'Microsoft JhengHei UI',
        'SimSun',
        'Consolas',
        'Cascadia Mono',
      ];
    }
    if (Platform.isMacOS) {
      return const ['PingFang SC', 'Helvetica Neue', 'San Francisco', 'Menlo'];
    }
    return const [
      'Noto Sans CJK SC',
      'Noto Sans',
      'Ubuntu',
      'DejaVu Sans',
      'Liberation Sans',
    ];
  }

  List<String> _parseLines(String output) {
    return output
        .split(RegExp(r'[\r\n]+'))
        .expand((line) => line.split(','))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }
}
