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
import 'package:git_gui_expand/core/services/git_runtime_installation_service.dart';
import 'package:git_gui_expand/core/services/installation_maintenance_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';
import 'package:git_gui_expand/core/theme/app_theme.dart';

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
      colorSchemePreference: AppColorSchemePreference.ocean,
      languagePreference: AppLanguagePreference.traditionalChinese,
      fontFamily: 'Noto Sans',
      fontScale: 1.1,
    );

    await settingsService.save(settings);
    final loaded = await settingsService.load();
    logger.infoEvent('test', 'test.normal', details: {'note': '普通日志内容'});
    logger.detailEvent('test', 'test.detail', details: {'note': '详细日志内容'});
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
    expect(normalLog, contains('test.normal'));
    expect(normalLog, isNot(contains('普通日志内容')));
    expect(normalLog, isNot(contains('test.detail')));
    expect(detailedLog, contains('test.normal'));
    expect(detailedLog, contains('普通日志内容'));
    expect(detailedLog, contains('test.detail'));
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
    expect(
      AppSettings.fromJson({'colorSchemePreference': 'violet'})
          .colorSchemePreference,
      AppColorSchemePreference.violet,
    );
    expect(
      AppSettings.fromJson({}).colorSchemePreference,
      AppColorSchemePreference.emerald,
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
      const AppLocalizations(AppLocalizations.simplifiedChinese)
          .tr('settings2'),
      '设置',
    );
    expect(
      const AppLocalizations(AppLocalizations.english).tr('settings2'),
      'Settings',
    );
    expect(
      const AppLocalizations(AppLocalizations.traditionalChinese)
          .tr('openRepository'),
      '開啟 Git 儲存庫',
    );
    expect(
      const AppLocalizations(AppLocalizations.english).tr('fetchAllRemotes'),
      'Fetch all remotes',
    );
    expect(
      const AppLocalizations(AppLocalizations.traditionalChinese)
          .tr('fetchAllRemotes'),
      '取得全部遠端',
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
    await tester.pumpWidget(
      const GitGuiExpandApp(
        initialColorSchemePreference: AppColorSchemePreference.ocean,
      ),
    );
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.brightness, Brightness.light);
    expect(app.darkTheme?.brightness, Brightness.dark);
    expect(
      app.theme?.colorScheme.primary,
      AppTheme.palette(AppColorSchemePreference.ocean).lightSeed,
    );
  });

  test('color schemes change the Material primary color', () {
    final emerald = AppTheme.light(
      colorScheme: AppColorSchemePreference.emerald,
    );
    final ocean = AppTheme.light(colorScheme: AppColorSchemePreference.ocean);
    final violetDark = AppTheme.dark(
      colorScheme: AppColorSchemePreference.violet,
    );

    expect(ocean.colorScheme.primary, isNot(emerald.colorScheme.primary));
    expect(
      ocean.scaffoldBackgroundColor,
      isNot(emerald.scaffoldBackgroundColor),
    );
    expect(
      violetDark.colorScheme.primary,
      AppTheme.palette(AppColorSchemePreference.violet).darkAccent,
    );
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
    logger.infoEvent('ui', 'ui.openRepository');
    logger.setLocale(AppLocalizations.traditionalChinese);
    logger.infoEvent('ui', 'settings.saved');
    await logger.flush();

    final normalLog = await logger.readRecent(AppLogType.normal);
    expect(normalLog, contains('Information event: ui.openRepository'));
    expect(normalLog, contains('資訊事件：settings.saved'));
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
      expect(source, contains(r"\$dialog.Title = '$escapedTitle'"));
      expect(source, contains("title: '打开 Git 仓库'"));
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
      expect(projectPage, contains("l10n.tr('projectFolder')"));
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

    expect(
      result.isSuccess,
      isTrue,
      reason: result.message.resolve(
        const AppLocalizations(AppLocalizations.english),
      ),
    );
    expect(result.shortcutPath, isNotNull);
    expect(await File(result.shortcutPath!).exists(), isTrue);
    expect(result.shortcutPath, endsWith('Git GUI Expand.lnk'));
  });

  test('project uses MIT and READMEs expose project badges', () async {
    final license = await File(
      '${Directory.current.path}${Platform.pathSeparator}LICENSE',
    ).readAsString();
    expect(license, startsWith('MIT License'));

    for (final name in ['README.md', 'README.zh-CN.md', 'README.zh-TW.md']) {
      final readme = await File(
        '${Directory.current.path}${Platform.pathSeparator}$name',
      ).readAsString();
      expect(readme, contains('actions/workflows/windows-release.yml'));
      expect(readme, contains('platform-Windows%2010%20%7C%2011'));
      expect(readme, contains('license-MIT-blue'));
      expect(
        readme,
        anyOf(
          contains('Git feature coverage'),
          contains('Git 功能覆盖'),
          contains('Git 功能覆蓋'),
        ),
      );
      expect(readme, contains('git clone'));
      expect(readme, contains('git stash'));
      expect(readme.indexOf('Git_Gui_Expand-<tag>-windows-x64.zip'), isNot(-1));
      expect(
        readme.indexOf('Git_Gui_Expand-<tag>-windows-x64.zip'),
        lessThan(
          readme.indexOf('Git_Gui_Expand-<tag>-windows-x64-PortableGit.zip'),
        ),
      );
      expect(readme, contains('https://git-scm.com/download/win'));
      expect(readme, contains('runtime/git/current/cmd'));
    }

    final notices = await File(
      '${Directory.current.path}${Platform.pathSeparator}docs'
      '${Platform.pathSeparator}PORTABLEGIT.md',
    ).readAsString();
    expect(notices, contains('runtime/git/'));
    expect(notices, contains('versions/'));
    expect(notices, contains('GIT-COPYING.txt'));
    expect(notices, contains('current.json'));
    expect(notices, contains('userdata/git-path-backups'));
    expect(notices, contains('tool/portablegit-runtime.lock.json'));
  });

  test(
    'installation maintenance keeps current version and user data',
    () async {
      final root = temporaryDirectory.path;
      final versions = Directory('$root${Platform.pathSeparator}versions');
      await Directory('${versions.path}${Platform.pathSeparator}0.9.6')
          .create(recursive: true);
      await Directory('${versions.path}${Platform.pathSeparator}0.9.5')
          .create(recursive: true);
      await storage.currentVersionFile.writeAsString('0.9.6\n');
      await File('$root${Platform.pathSeparator}git_gui_expand.exe')
          .writeAsString('old');
      await Directory('$root${Platform.pathSeparator}data')
          .create(recursive: true);
      final updates = Directory(
        '$root${Platform.pathSeparator}userdata'
        '${Platform.pathSeparator}updates',
      );
      await updates.create(recursive: true);
      await File(
        '${updates.path}${Platform.pathSeparator}Git_Gui_Expand-v0.9.5.zip',
      ).writeAsString('old zip');
      await File('${updates.path}${Platform.pathSeparator}download.part')
          .writeAsString('partial');
      await Directory('${updates.path}${Platform.pathSeparator}stage-v0.9.5')
          .create(recursive: true);
      await File('${updates.path}${Platform.pathSeparator}launcher.log')
          .writeAsString('keep');
      final settings = File(
        '$root${Platform.pathSeparator}userdata'
        '${Platform.pathSeparator}settings.json',
      );
      await settings.writeAsString('{}');

      final service = InstallationMaintenanceService(
        storage: storage,
        logService: logger,
      );
      final scan = await service.scan();
      expect(scan.currentVersion, '0.9.6');
      expect(scan.items.any((item) => item.name == '0.9.5'), isTrue);
      expect(scan.items.any((item) => item.name.endsWith('.zip')), isTrue);

      final result = await service.cleanup(scan);
      expect(result.failed, isEmpty);
      expect(
        await Directory('${versions.path}${Platform.pathSeparator}0.9.6')
            .exists(),
        isTrue,
      );
      expect(
        await Directory('${versions.path}${Platform.pathSeparator}0.9.5')
            .exists(),
        isFalse,
      );
      expect(
        await Directory('$root${Platform.pathSeparator}data').exists(),
        isFalse,
      );
      expect(await File(settings.path).exists(), isTrue);
      expect(
        await File('${updates.path}${Platform.pathSeparator}launcher.log')
            .exists(),
        isTrue,
      );
      expect((await service.scan()).items, isEmpty);
    },
  );

  test(
    'maintenance keeps active and previous PortableGit runtimes only',
    () async {
      final root = temporaryDirectory.path;
      final runtimeVersions = storage.gitRuntimeVersionsDirectory;
      for (final name in [
        'PortableGit-active',
        'PortableGit-previous',
        'PortableGit-old',
      ]) {
        await Directory('${runtimeVersions.path}${Platform.pathSeparator}$name')
            .create(recursive: true);
      }
      final pointerStore = GitRuntimePointerStore(storage: storage);
      await pointerStore.write(
        GitRuntimePointer(
          activeVersion: 'PortableGit-active',
          activePath: 'versions/PortableGit-active',
          previousVersion: 'PortableGit-previous',
          previousPath: 'versions/PortableGit-previous',
          activatedAt: DateTime.utc(2026, 11, 23),
        ),
      );
      final updates = Directory(
        '$root${Platform.pathSeparator}userdata'
        '${Platform.pathSeparator}updates',
      );
      await updates.create(recursive: true);
      final gitStage = Directory(
        '${updates.path}${Platform.pathSeparator}'
        'git-stage-PortableGit-next',
      );
      await gitStage.create();
      await File('${gitStage.path}${Platform.pathSeparator}payload.txt')
          .writeAsString('staged');
      final settings = await storage.ensureDataDirectory().then(
        (directory) =>
            File('${directory.path}${Platform.pathSeparator}settings.json'),
      );
      await settings.writeAsString('{}');
      final repository = File('$root${Platform.pathSeparator}repository.txt');
      await repository.writeAsString('keep');

      final service = InstallationMaintenanceService(
        storage: storage,
        logService: logger,
      );
      final scan = await service.scan();

      expect(
        scan.items.any(
          (item) =>
              item.name == 'PortableGit-old' &&
              item.kind == MaintenanceItemKind.obsoleteGitRuntime,
        ),
        isTrue,
      );
      expect(
        scan.items.any(
          (item) =>
              item.name == 'git-stage-PortableGit-next' &&
              item.kind == MaintenanceItemKind.gitRuntimeStaging,
        ),
        isTrue,
      );
      expect(
        scan.items.any((item) => item.name == 'PortableGit-active'),
        isFalse,
      );
      expect(
        scan.items.any((item) => item.name == 'PortableGit-previous'),
        isFalse,
      );

      final cleanup = await service.cleanup(scan);
      expect(cleanup.failed, isEmpty);
      expect(
        await Directory(
          '${runtimeVersions.path}${Platform.pathSeparator}'
          'PortableGit-active',
        ).exists(),
        isTrue,
      );
      expect(
        await Directory(
          '${runtimeVersions.path}${Platform.pathSeparator}'
          'PortableGit-previous',
        ).exists(),
        isTrue,
      );
      expect(
        await Directory(
          '${runtimeVersions.path}${Platform.pathSeparator}PortableGit-old',
        ).exists(),
        isFalse,
      );
      expect(await gitStage.exists(), isFalse);
      expect(await settings.exists(), isTrue);
      expect(await repository.exists(), isTrue);
    },
  );
}
