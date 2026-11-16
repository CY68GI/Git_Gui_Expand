import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_info.dart';
import 'core/localization/app_localizations.dart';
import 'core/models/settings_models.dart';
import 'core/services/app_log_service.dart';
import 'core/services/app_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/project/project_page.dart';

class GitGuiExpandApp extends StatefulWidget {
  const GitGuiExpandApp({
    super.key,
    this.initialRepositoryPath,
    this.initialLanguagePreference = AppLanguagePreference.system,
  });

  final String? initialRepositoryPath;
  final AppLanguagePreference initialLanguagePreference;

  @override
  State<GitGuiExpandApp> createState() => _GitGuiExpandAppState();
}

class _GitGuiExpandAppState extends State<GitGuiExpandApp>
    with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  String _fontFamily = AppSettings.defaultFontFamily;
  double _fontScale = AppSettings.defaultFontScale;
  late AppLanguagePreference _languagePreference;

  @override
  void initState() {
    super.initState();
    _languagePreference = widget.initialLanguagePreference;
    AppLogService.instance.setLocale(
      AppLocalizations.localeForPreference(_languagePreference),
    );
    WidgetsBinding.instance.addObserver(this);
    const storage = AppStorageService();
    AppLogService.instance.info(
      'app',
      'Git GUI Expand v${AppInfo.version} 启动；软件目录=${storage.softwareDirectory}',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    AppLogService.instance.detail(
      'theme',
      '设备外观变化：${brightness.name}；当前模式=$_themeMode',
    );
    if (_themeMode == ThemeMode.system) {
      setState(() {});
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (_languagePreference != AppLanguagePreference.system) {
      return;
    }
    AppLogService.instance.setLocale(
      AppLocalizations.resolveLocaleList(locales),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedFont = _fontFamily.trim().isEmpty ? null : _fontFamily;
    return MaterialApp(
      title: AppInfo.englishName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(fontFamily: selectedFont),
      darkTheme: AppTheme.dark(fontFamily: selectedFont),
      themeMode: _themeMode,
      locale: switch (_languagePreference) {
        AppLanguagePreference.system => null,
        AppLanguagePreference.english => AppLocalizations.english,
        AppLanguagePreference.simplifiedChinese =>
          AppLocalizations.simplifiedChinese,
        AppLanguagePreference.traditionalChinese =>
          AppLocalizations.traditionalChinese,
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (locales, supportedLocales) {
        return AppLocalizations.resolveLocaleList(locales);
      },
      themeAnimationDuration: const Duration(milliseconds: 220),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(_fontScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: ProjectPage(
        initialRepositoryPath: widget.initialRepositoryPath,
        onThemeModeChanged: (mode) {
          if (_themeMode != mode) {
            setState(() => _themeMode = mode);
          }
        },
        onFontFamilyChanged: (fontFamily) {
          if (_fontFamily != fontFamily) {
            setState(() => _fontFamily = fontFamily);
          }
        },
        onFontScaleChanged: (fontScale) {
          final bounded = fontScale
              .clamp(AppSettings.minFontScale, AppSettings.maxFontScale)
              .toDouble();
          if (_fontScale != bounded) {
            setState(() => _fontScale = bounded);
          }
        },
        onLanguagePreferenceChanged: (preference) {
          if (_languagePreference != preference) {
            AppLogService.instance.setLocale(
              AppLocalizations.localeForPreference(preference),
            );
            setState(() => _languagePreference = preference);
          }
        },
      ),
    );
  }
}
