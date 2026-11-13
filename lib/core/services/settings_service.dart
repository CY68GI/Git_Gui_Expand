import 'dart:convert';
import 'dart:io';

import '../models/settings_models.dart';
import 'app_log_service.dart';
import 'app_storage_service.dart';

class SettingsService {
  SettingsService({
    this.configDirectory,
    this.storage = const AppStorageService(),
    AppLogService? logService,
  }) : logService = logService ?? AppLogService.instance;

  final String? configDirectory;
  final AppStorageService storage;
  final AppLogService logService;

  Future<AppSettings> load() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) {
        final migrated = await _migrateLegacySettings(file);
        if (migrated != null) {
          return migrated;
        }
        logService.detail('settings', '设置文件不存在，使用默认值：${file.path}');
        return const AppSettings();
      }
      final text = await file.readAsString();
      if (text.trim().isEmpty) {
        return const AppSettings();
      }
      final decoded = jsonDecode(text);
      final settings = decoded is Map<String, dynamic>
          ? AppSettings.fromJson(decoded)
          : const AppSettings();
      logService.detail('settings', '已读取设置：${file.path}');
      return settings;
    } catch (error) {
      logService.error('settings', '读取设置失败：$error');
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    final file = await _settingsFile();
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(settings.toJson()), flush: true);
    logService.detail('settings', '已保存设置：${file.path}');
  }

  Future<File> _settingsFile() async {
    if (configDirectory != null && configDirectory!.isNotEmpty) {
      return File('${configDirectory!}${Platform.pathSeparator}settings.json');
    }
    return storage.settingsFile;
  }

  Future<AppSettings?> _migrateLegacySettings(File targetFile) async {
    if (configDirectory != null) return null;
    final legacy = _legacySettingsFile();
    if (legacy == null || !await legacy.exists()) {
      return null;
    }
    try {
      final text = await legacy.readAsString();
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return null;
      final settings = AppSettings.fromJson(decoded);
      await targetFile.parent.create(recursive: true);
      await targetFile.writeAsString(text, flush: true);
      logService.info('settings', '已将旧设置迁移到软件目录：${targetFile.path}');
      return settings;
    } catch (error) {
      logService.warning('settings', '旧设置迁移失败：$error');
      return null;
    }
  }

  File? _legacySettingsFile() {
    final env = Platform.environment;
    String? base;
    if (Platform.isWindows) {
      base = env['APPDATA'] ?? env['LOCALAPPDATA'];
    } else if (Platform.isMacOS) {
      final home = env['HOME'];
      if (home != null) {
        base = '$home/Library/Application Support';
      }
    } else {
      base = env['XDG_CONFIG_HOME'];
      if (base == null && env['HOME'] != null) {
        base = '${env['HOME']}/.config';
      }
    }
    if (base == null || base.isEmpty) return null;
    return File(
      '$base${Platform.pathSeparator}GitGuiExpand'
      '${Platform.pathSeparator}settings.json',
    );
  }
}
