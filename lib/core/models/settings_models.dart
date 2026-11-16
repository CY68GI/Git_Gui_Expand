enum SizeUnitSystem { binary, decimal }

enum SizeBaseUnit { byte, bit }

enum AppThemePreference { system, light, dark }

enum AppColorSchemePreference { emerald, ocean, violet, amber, rose }

enum AppLanguagePreference {
  system,
  english,
  simplifiedChinese,
  traditionalChinese,
}

class AppSettings {
  static const int currentSettingsVersion = 4;
  static const String defaultFontFamily = 'Noto Sans SC';
  static const double minFontScale = 0.9;
  static const double defaultFontScale = 1.0;
  static const double maxFontScale = 1.1;

  const AppSettings({
    this.unitSystem = SizeUnitSystem.binary,
    this.baseUnit = SizeBaseUnit.byte,
    this.showHiddenFiles = false,
    this.themePreference = AppThemePreference.system,
    this.colorSchemePreference = AppColorSchemePreference.emerald,
    this.languagePreference = AppLanguagePreference.system,
    this.fontFamily = defaultFontFamily,
    this.fontScale = defaultFontScale,
    this.settingsVersion = currentSettingsVersion,
  });

  final SizeUnitSystem unitSystem;
  final SizeBaseUnit baseUnit;
  final bool showHiddenFiles;
  final AppThemePreference themePreference;
  final AppColorSchemePreference colorSchemePreference;
  final AppLanguagePreference languagePreference;
  final String fontFamily;
  final double fontScale;
  final int settingsVersion;

  AppSettings copyWith({
    SizeUnitSystem? unitSystem,
    SizeBaseUnit? baseUnit,
    bool? showHiddenFiles,
    AppThemePreference? themePreference,
    AppColorSchemePreference? colorSchemePreference,
    AppLanguagePreference? languagePreference,
    String? fontFamily,
    double? fontScale,
    int? settingsVersion,
  }) {
    return AppSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      baseUnit: baseUnit ?? this.baseUnit,
      showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
      themePreference: themePreference ?? this.themePreference,
      colorSchemePreference:
          colorSchemePreference ?? this.colorSchemePreference,
      languagePreference: languagePreference ?? this.languagePreference,
      fontFamily: fontFamily ?? this.fontFamily,
      fontScale: (fontScale ?? this.fontScale)
          .clamp(minFontScale, maxFontScale)
          .toDouble(),
      settingsVersion: settingsVersion ?? this.settingsVersion,
    );
  }

  Map<String, Object> toJson() => {
    'unitSystem': unitSystem.name,
    'baseUnit': baseUnit.name,
    'showHiddenFiles': showHiddenFiles,
    'themePreference': themePreference.name,
    'colorSchemePreference': colorSchemePreference.name,
    'languagePreference': languagePreference.name,
    'fontFamily': fontFamily,
    'fontScale': fontScale,
    'settingsVersion': settingsVersion,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final storedVersion = (json['settingsVersion'] as num?)?.toInt() ?? 1;
    final storedFont = (json['fontFamily'] as String? ?? '').trim();
    return AppSettings(
      unitSystem: SizeUnitSystem.values.firstWhere(
        (value) => value.name == json['unitSystem'],
        orElse: () => SizeUnitSystem.binary,
      ),
      baseUnit: SizeBaseUnit.values.firstWhere(
        (value) => value.name == json['baseUnit'],
        orElse: () => SizeBaseUnit.byte,
      ),
      showHiddenFiles: json['showHiddenFiles'] == true,
      themePreference: AppThemePreference.values.firstWhere(
        (value) => value.name == json['themePreference'],
        orElse: () => AppThemePreference.system,
      ),
      colorSchemePreference: AppColorSchemePreference.values.firstWhere(
        (value) => value.name == json['colorSchemePreference'],
        orElse: () => AppColorSchemePreference.emerald,
      ),
      languagePreference: AppLanguagePreference.values.firstWhere(
        (value) => value.name == json['languagePreference'],
        orElse: () => AppLanguagePreference.system,
      ),
      fontFamily: storedVersion < 2 && storedFont.isEmpty
          ? defaultFontFamily
          : json['fontFamily'] is String
          ? storedFont
          : defaultFontFamily,
      fontScale:
          (json['fontScale'] is num
                  ? (json['fontScale'] as num).toDouble()
                  : defaultFontScale)
              .clamp(minFontScale, maxFontScale)
              .toDouble(),
      settingsVersion: currentSettingsVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.unitSystem == unitSystem &&
        other.baseUnit == baseUnit &&
        other.showHiddenFiles == showHiddenFiles &&
        other.themePreference == themePreference &&
        other.colorSchemePreference == colorSchemePreference &&
        other.languagePreference == languagePreference &&
        other.fontFamily == fontFamily &&
        other.fontScale == fontScale &&
        other.settingsVersion == settingsVersion;
  }

  @override
  int get hashCode => Object.hash(
    unitSystem,
    baseUnit,
    showHiddenFiles,
    themePreference,
    colorSchemePreference,
    languagePreference,
    fontFamily,
    fontScale,
    settingsVersion,
  );
}
