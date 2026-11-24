import 'package:flutter/material.dart';

import '../../l10n/app_l10n.dart';
import '../../l10n/app_l10n_registry.dart';
import '../models/settings_models.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const Locale english = Locale('en');
  static const Locale simplifiedChinese = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hans',
  );
  static const Locale traditionalChinese = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  );

  static const List<Locale> supportedLocales = [
    english,
    simplifiedChinese,
    traditionalChinese,
  ];

  static final Map<String, AppL10n> _generatedCache = {};

  static AppLocalizations of(BuildContext context) {
    final generated = Localizations.of<AppL10n>(context, AppL10n);
    return generated == null
        ? const AppLocalizations(simplifiedChinese)
        : AppLocalizations(Localizations.localeOf(context));
  }

  String get languageCode {
    if (locale.languageCode == 'en') return 'en';
    if (locale.languageCode == 'zh' &&
        (locale.scriptCode == 'Hant' ||
            const {'TW', 'HK', 'MO'}.contains(locale.countryCode))) {
      return 'zh_Hant';
    }
    return 'zh';
  }

  String tr(String key, [Map<String, Object?> values = const {}]) {
    return localizeAppMessage(_generated, key, values);
  }

  AppL10n get _generated {
    final resolved = resolveLocale(locale);
    final cacheKey = '${resolved.languageCode}_${resolved.scriptCode ?? ''}';
    return _generatedCache.putIfAbsent(cacheKey, () => lookupAppL10n(resolved));
  }

  static Locale resolveLocale(Locale locale) {
    if (locale.languageCode == 'en') return english;
    if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hant' ||
          const {'TW', 'HK', 'MO'}.contains(locale.countryCode)) {
        return traditionalChinese;
      }
      return simplifiedChinese;
    }
    return english;
  }

  static Locale resolveLocaleList(List<Locale>? locales) {
    if (locales != null) {
      for (final locale in locales) {
        if (locale.languageCode == 'en' || locale.languageCode == 'zh') {
          return resolveLocale(locale);
        }
      }
    }
    return english;
  }

  static Locale localeForPreference(AppLanguagePreference preference) {
    return switch (preference) {
      AppLanguagePreference.system => resolveLocale(
        WidgetsBinding.instance.platformDispatcher.locale,
      ),
      AppLanguagePreference.english => english,
      AppLanguagePreference.simplifiedChinese => simplifiedChinese,
      AppLanguagePreference.traditionalChinese => traditionalChinese,
    };
  }

  static String languageOptionLabel(
    AppLanguagePreference preference, {
    Locale? systemLocale,
  }) {
    return switch (preference) {
      AppLanguagePreference.system => lookupAppL10n(
        resolveLocale(
          systemLocale ?? WidgetsBinding.instance.platformDispatcher.locale,
        ),
      ).followSystemLabel,
      AppLanguagePreference.english => lookupAppL10n(
        english,
      ).languageEnglishOptionLabel,
      AppLanguagePreference.simplifiedChinese => lookupAppL10n(
        simplifiedChinese,
      ).languageSimplifiedChineseOptionLabel,
      AppLanguagePreference.traditionalChinese => lookupAppL10n(
        traditionalChinese,
      ).languageTraditionalChineseOptionLabel,
    };
  }

  static String languageOptionDescription(
    AppLanguagePreference preference, {
    Locale? systemLocale,
  }) {
    return switch (preference) {
      AppLanguagePreference.system => lookupAppL10n(
        resolveLocale(
          systemLocale ?? WidgetsBinding.instance.platformDispatcher.locale,
        ),
      ).followSystemDescription,
      AppLanguagePreference.english => lookupAppL10n(
        english,
      ).languageEnglishDescription,
      AppLanguagePreference.simplifiedChinese => lookupAppL10n(
        simplifiedChinese,
      ).languageSimplifiedChineseDescription,
      AppLanguagePreference.traditionalChinese => lookupAppL10n(
        traditionalChinese,
      ).languageTraditionalChineseDescription,
    };
  }

  static void validateTranslations() {
    assert(
      AppL10n.supportedLocales.any((locale) => locale.languageCode == 'en'),
    );
    assert(
      AppL10n.supportedLocales.any((locale) => locale.languageCode == 'zh'),
    );
  }
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
