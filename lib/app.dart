import 'package:flutter/material.dart';

import 'core/constants/app_info.dart';
import 'core/services/app_log_service.dart';
import 'core/services/app_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/project/project_page.dart';

class GitGuiExpandApp extends StatefulWidget {
  const GitGuiExpandApp({super.key, this.initialRepositoryPath});

  final String? initialRepositoryPath;

  @override
  State<GitGuiExpandApp> createState() => _GitGuiExpandAppState();
}

class _GitGuiExpandAppState extends State<GitGuiExpandApp>
    with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  String _fontFamily = '';

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final selectedFont = _fontFamily.trim().isEmpty ? null : _fontFamily;
    return MaterialApp(
      title: AppInfo.englishName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(fontFamily: selectedFont),
      darkTheme: AppTheme.dark(fontFamily: selectedFont),
      themeMode: _themeMode,
      themeAnimationDuration: const Duration(milliseconds: 220),
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
      ),
    );
  }
}
