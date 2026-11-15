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
    _log.detail('dialog', '打开 Windows“打开”对话框，初始目录=${initialDirectory ?? '无'}');

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
\$dialog = New-Object System.Windows.Forms.OpenFileDialog
\$dialog.Title = '打开 Git 仓库'
\$dialog.Filter = '文件夹|*.*'
\$dialog.CheckFileExists = \$false
\$dialog.CheckPathExists = \$true
\$dialog.ValidateNames = \$false
\$dialog.Multiselect = \$false
\$dialog.RestoreDirectory = \$true
\$dialog.FileName = '选择当前文件夹'
if ('$selectedPath'.Length -gt 0 -and (Test-Path -LiteralPath '$selectedPath')) {
  \$dialog.InitialDirectory = '$selectedPath'
}
if (\$dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
  \$selected = [System.IO.Path]::GetDirectoryName(\$dialog.FileName)
  if ([string]::IsNullOrWhiteSpace(\$selected)) { \$selected = \$dialog.InitialDirectory }
  [System.IO.File]::WriteAllText('$outputPath', \$selected, (New-Object System.Text.UTF8Encoding(\$false)))
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
      _log.detail('dialog', '“打开”对话框返回：$path');
      return path.isEmpty ? null : path;
    } finally {
      if (await resultFile.exists()) {
        await resultFile.delete();
      }
    }
  }

  Future<void> openDirectory(String path) async {
    final directory = Directory(path).absolute.path;
    if (!await Directory(directory).exists()) {
      throw FileSystemException('项目目录不存在', directory);
    }
    _log.info('system', '打开项目目录：$directory');
    if (Platform.isWindows) {
      await Process.start(
        'explorer.exe',
        [directory],
        mode: ProcessStartMode.detached,
        runInShell: false,
      );
      return;
    }
    if (Platform.isMacOS) {
      await Process.start(
        'open',
        [directory],
        mode: ProcessStartMode.detached,
        runInShell: false,
      );
      return;
    }
    if (Platform.isLinux) {
      await Process.start(
        'xdg-open',
        [directory],
        mode: ProcessStartMode.detached,
        runInShell: false,
      );
      return;
    }
    throw UnsupportedError('当前平台不支持打开项目目录。');
  }

  String _escapePowerShell(String value) => value.replaceAll("'", "''");
}
