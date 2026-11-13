import 'dart:io';

import 'app_log_service.dart';
import 'app_storage_service.dart';

class FolderPickerService {
  const FolderPickerService({
    this.logService,
    this.storage = const AppStorageService(),
  });

  final AppLogService? logService;
  final AppStorageService storage;

  AppLogService get _log => logService ?? AppLogService.instance;

  Future<String?> pickRepositoryFolder({String? initialDirectory}) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('当前版本仅支持 Windows 文件夹选择。');
    }
    _log.detail('dialog', '打开文件夹选择器，初始目录=${initialDirectory ?? '无'}');

    final dataDirectory = await storage.ensureDataDirectory();
    final resultFile = File(
      '${dataDirectory.path}${Platform.pathSeparator}'
      'picker-${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    final selectedPath = _escapePowerShell(initialDirectory ?? '');
    final outputPath = _escapePowerShell(resultFile.path);
    final script =
        '''
Add-Type -AssemblyName System.Windows.Forms
\$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
\$dialog.Description = '选择已经初始化 Git 的仓库根目录'
\$dialog.ShowNewFolderButton = \$false
if ('$selectedPath'.Length -gt 0) { \$dialog.SelectedPath = '$selectedPath' }
if (\$dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
  [System.IO.File]::WriteAllText('$outputPath', \$dialog.SelectedPath, (New-Object System.Text.UTF8Encoding(\$false)))
}
''';

    try {
      final process = await Process.run('powershell.exe', [
        '-NoProfile',
        '-STA',
        '-NonInteractive',
        '-Command',
        script,
      ], runInShell: false);
      if (process.exitCode != 0) {
        throw Exception(
          (process.stderr as String).trim().isEmpty
              ? '无法打开文件夹选择器。'
              : (process.stderr as String).trim(),
        );
      }
      if (!await resultFile.exists()) {
        _log.detail('dialog', '文件夹选择器已取消');
        return null;
      }
      final path = (await resultFile.readAsString()).trim();
      _log.detail('dialog', '文件夹选择器返回：$path');
      return path.isEmpty ? null : path;
    } finally {
      if (await resultFile.exists()) {
        await resultFile.delete();
      }
    }
  }

  String _escapePowerShell(String value) => value.replaceAll("'", "''");
}
