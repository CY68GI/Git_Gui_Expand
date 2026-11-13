import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/app.dart';
import 'package:git_gui_expand/core/models/settings_models.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
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
    expect(const AppSettings().fontFamily, isEmpty);
    final settingsService = SettingsService(
      storage: storage,
      logService: logger,
    );
    const settings = AppSettings(
      unitSystem: SizeUnitSystem.decimal,
      baseUnit: SizeBaseUnit.bit,
      themePreference: AppThemePreference.dark,
      fontFamily: 'Noto Sans',
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
}
