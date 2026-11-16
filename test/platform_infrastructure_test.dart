import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/app.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/models/settings_models.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/desktop_shortcut_service.dart';
import 'package:git_gui_expand/core/services/font_catalog_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';

void main() {
  late Directory temporaryDirectory;
  late AppStorageService storage;
  late AppLogService logger;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'git_gui_infrastructure_',
    );
    storage = AppStorageService(
      softwareDirectoryOverride: temporaryDirectory.path,
    );
    logger = AppLogService(storage: storage);
  });

  tearDown(() async {
    await logger.flush();
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('settings and logs stay under the software data directory', () async {
    expect(const AppSettings().fontFamily, AppSettings.defaultFontFamily);
    final settingsService = SettingsService(
      storage: storage,
      logService: logger,
    );
    const settings = AppSettings(
      unitSystem: SizeUnitSystem.decimal,
      baseUnit: SizeBaseUnit.bit,
      themePreference: AppThemePreference.dark,
      languagePreference: AppLanguagePreference.traditionalChinese,
      fontFamily: 'Noto Sans',
      fontScale: 1.1,
    );

    await settingsService.save(settings);
    final loaded = await settingsService.load();
    logger.info('test', '普通日志内容');
    logger.detail('test', '详细日志内容');
    await logger.flush();

    final settingsPath = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}userdata'
      '${Platform.pathSeparator}settings.json',
    );
    final normalLog = await logger.readRecent(AppLogType.normal);
    final detailedLog = await logger.readRecent(AppLogType.detailed);

    expect(await settingsPath.exists(), isTrue);
    expect(loaded, settings);
    expect(logger.logsDirectoryPath, contains('userdata'));
    expect(normalLog, contains('普通日志内容'));
    expect(normalLog, isNot(contains('详细日志内容')));
    expect(detailedLog, contains('普通日志内容'));
    expect(detailedLog, contains('详细日志内容'));
    expect(
      AppSettings.fromJson({'fontScale': 10}).fontScale,
      AppSettings.maxFontScale,
    );
    expect(
      AppSettings.fromJson({'fontScale': 0.1}).fontScale,
      AppSettings.minFontScale,
    );
    expect(
      AppSettings.fromJson({'fontFamily': ''}).fontFamily,
      AppSettings.defaultFontFamily,
    );
    expect(
      AppSettings.fromJson({
        'settingsVersion': AppSettings.currentSettingsVersion,
        'fontFamily': '',
      }).fontFamily,
      isEmpty,
    );
    expect(
      AppSettings.fromJson({'settingsVersion': 1, 'fontFamily': ''}).fontFamily,
      AppSettings.defaultFontFamily,
    );
    expect(
      AppSettings.fromJson({'settingsVersion': 2, 'fontFamily': ''}).fontFamily,
      isEmpty,
    );
    expect(
      AppSettings.fromJson({}).languagePreference,
      AppLanguagePreference.system,
    );
    expect(
      AppSettings.fromJson({'languagePreference': 'simplifiedChinese'})
          .languagePreference,
      AppLanguagePreference.simplifiedChinese,
    );
  });

  test('language resolution supports English and both Chinese scripts', () {
    AppLocalizations.validateTranslations();
    expect(
      AppLocalizations.resolveLocale(const Locale('en', 'US')),
      AppLocalizations.english,
    );
    expect(
      AppLocalizations.resolveLocale(const Locale('zh', 'CN')),
      AppLocalizations.simplifiedChinese,
    );
    expect(
      AppLocalizations.resolveLocale(const Locale('zh', 'TW')),
      AppLocalizations.traditionalChinese,
    );
    expect(
      AppLocalizations.resolveLocale(const Locale('zh', 'HK')),
      AppLocalizations.traditionalChinese,
    );
    expect(
      AppLocalizations.resolveLocale(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ),
      AppLocalizations.traditionalChinese,
    );
    expect(
      AppLocalizations.resolveLocaleList(const [Locale('fr', 'FR')]),
      AppLocalizations.english,
    );
    expect(
      const AppLocalizations(AppLocalizations.simplifiedChinese).tr('设置'),
      '设置',
    );
    expect(
      const AppLocalizations(AppLocalizations.english).tr('设置'),
      'Settings',
    );
    expect(
      const AppLocalizations(AppLocalizations.traditionalChinese).tr('打开设置'),
      '開啟設定',
    );
    expect(
      const AppLocalizations(AppLocalizations.english).tr('移动 2 项到 docs'),
      'Move 2 items to docs',
    );
    expect(
      const AppLocalizations(AppLocalizations.english)
          .tr('已加入执行计划：重命名 README.md。尚未执行任何 Git 变更。'),
      'Added to the operation plan: Rename README.md. '
      'No Git changes have run.',
    );
    expect(
      const AppLocalizations(AppLocalizations.traditionalChinese)
          .tr('删除 3 个项目'),
      '刪除 3 個項目',
    );
    expect(
      const AppLocalizations(AppLocalizations.english).tr('已按顺序执行全部 4 步操作。'),
      'Executed all 4 steps in order.',
    );
    expect(
      AppLocalizations.languageOptionLabel(
        AppLanguagePreference.system,
        systemLocale: const Locale('en', 'US'),
      ),
      'Follow system',
    );
    expect(
      AppLocalizations.languageOptionDescription(
        AppLanguagePreference.system,
        systemLocale: const Locale('zh', 'CN'),
      ),
      '使用操作系统设置的语言。',
    );
    expect(
      AppLocalizations.languageOptionLabel(
        AppLanguagePreference.system,
        systemLocale: const Locale('zh', 'TW'),
      ),
      '跟隨系統',
    );
    expect(
      AppLocalizations.languageOptionDescription(
        AppLanguagePreference.system,
        systemLocale: const Locale('en', 'US'),
      ),
      'Use the language selected in the operating system.',
    );
  });

  testWidgets('application exposes light, dark and system theme modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GitGuiExpandApp());
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.brightness, Brightness.light);
    expect(app.darkTheme?.brightness, Brightness.dark);
  });

  test('font catalog returns installed fonts or platform fallbacks', () async {
    final fonts = await FontCatalogService(logService: logger)
        .loadInstalledFonts();

    expect(fonts, isNotEmpty);
    if (Platform.isWindows) {
      expect(fonts, contains('Segoe UI'));
    }
  });

  test('new log entries use the selected interface language', () async {
    logger.setLocale(AppLocalizations.english);
    logger.info('ui', '打开 Git 仓库');
    logger.setLocale(AppLocalizations.traditionalChinese);
    logger.info('ui', '设置已保存');
    await logger.flush();

    final normalLog = await logger.readRecent(AppLogType.normal);
    expect(normalLog, contains('Open Git repository'));
    expect(normalLog, contains('設定已儲存'));
  });

  test(
    'Windows picker uses the native Open dialog and can open project folder',
    () async {
      final source = await File(
        '${Directory.current.path}${Platform.pathSeparator}lib'
        '${Platform.pathSeparator}core${Platform.pathSeparator}services'
        '${Platform.pathSeparator}folder_picker_service.dart',
      ).readAsString();

      expect(source, contains('System.Windows.Forms.OpenFileDialog'));
      expect(source, contains(r"$dialog.Title = '打开 Git 仓库'"));
      expect(source, isNot(contains('FolderBrowserDialog')));
      expect(source, contains("'explorer.exe'"));
      expect(source, contains(r"'/select,$file'"));
      expect(source, contains('openFileWithDefaultApp'));
      expect(
        source,
        contains(r'Start-Process -FilePath $env:GIT_GUI_OPEN_FILE'),
      );
      final projectPage = await File(
        '${Directory.current.path}${Platform.pathSeparator}lib'
        '${Platform.pathSeparator}features${Platform.pathSeparator}project'
        '${Platform.pathSeparator}project_page.dart',
      ).readAsString();
      expect(projectPage, contains("l10n.tr('项目目录')"));
    },
  );

  test('desktop shortcut targets the stable Launcher on Windows', () async {
    final source = await File(
      '${Directory.current.path}${Platform.pathSeparator}lib'
      '${Platform.pathSeparator}core${Platform.pathSeparator}services'
      '${Platform.pathSeparator}desktop_shortcut_service.dart',
    ).readAsString();

    expect(source, contains('storage.launcherFile'));
    expect(source, contains('Git GUI Expand.lnk'));
    expect(source, contains('WScript.Shell'));
    expect(source, contains(r'$shortcut.TargetPath'));
  });

  test('desktop shortcut service creates a Windows shortcut', () async {
    if (!Platform.isWindows) return;
    final desktop = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}Desktop',
    );
    await desktop.create(recursive: true);
    final result = await DesktopShortcutService(
      storage: storage,
      logService: logger,
      desktopDirectoryOverride: desktop.path,
    ).create();

    expect(result.isSuccess, isTrue, reason: result.message);
    expect(result.shortcutPath, isNotNull);
    expect(await File(result.shortcutPath!).exists(), isTrue);
    expect(result.shortcutPath, endsWith('Git GUI Expand.lnk'));
  });
}
