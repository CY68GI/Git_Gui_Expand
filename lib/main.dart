import 'package:flutter/material.dart';

import 'app.dart';
import 'core/localization/app_localizations.dart';
import 'core/models/settings_models.dart';
import 'core/services/app_log_service.dart';
import 'core/services/app_storage_service.dart';
import 'core/services/settings_service.dart';

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogService.instance.setLocale(
    AppLocalizations.localeForPreference(AppLanguagePreference.system),
  );
  const storage = AppStorageService();
  final settings = await SettingsService(storage: storage).load();
  AppLogService.instance.setLocale(
    AppLocalizations.localeForPreference(settings.languagePreference),
  );
  runApp(
    GitGuiExpandApp(
      initialRepositoryPath: arguments.isEmpty ? null : arguments.first,
      initialLanguagePreference: settings.languagePreference,
    ),
  );
}
