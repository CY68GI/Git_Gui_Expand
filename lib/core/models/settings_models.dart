enum SizeUnitSystem { binary, decimal }

enum SizeBaseUnit { byte, bit }

enum AppThemePreference { system, light, dark }

class AppSettings {
  static const String defaultFontFamily = 'Noto Sans SC';
  static const double minFontScale = 0.9;
  static const double defaultFontScale = 1.0;
  static const double maxFontScale = 1.1;

  const AppSettings({
    this.unitSystem = SizeUnitSystem.binary,
    this.baseUnit = SizeBaseUnit.byte,
    this.showHiddenFiles = false,
    this.themePreference = AppThemePreference.system,
    this.fontFamily = defaultFontFamily,
    this.fontScale = defaultFontScale,
  });

  final SizeUnitSystem unitSystem;
  final SizeBaseUnit baseUnit;
  final bool showHiddenFiles;
  final AppThemePreference themePreference;
  final String fontFamily;
  final double fontScale;

  AppSettings copyWith({
    SizeUnitSystem? unitSystem,
    SizeBaseUnit? baseUnit,
    bool? showHiddenFiles,
    AppThemePreference? themePreference,
    String? fontFamily,
    double? fontScale,
  }) {
    return AppSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      baseUnit: baseUnit ?? this.baseUnit,
      showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
      themePreference: themePreference ?? this.themePreference,
      fontFamily: fontFamily ?? this.fontFamily,
      fontScale: (fontScale ?? this.fontScale)
          .clamp(minFontScale, maxFontScale)
          .toDouble(),
    );
  }

  Map<String, Object> toJson() => {
    'unitSystem': unitSystem.name,
    'baseUnit': baseUnit.name,
    'showHiddenFiles': showHiddenFiles,
    'themePreference': themePreference.name,
    'fontFamily': fontFamily,
    'fontScale': fontScale,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
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
      fontFamily: json['fontFamily'] is String
          ? (json['fontFamily'] as String).trim()
          : defaultFontFamily,
      fontScale:
          (json['fontScale'] is num
                  ? (json['fontScale'] as num).toDouble()
                  : defaultFontScale)
              .clamp(minFontScale, maxFontScale)
              .toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.unitSystem == unitSystem &&
        other.baseUnit == baseUnit &&
        other.showHiddenFiles == showHiddenFiles &&
        other.themePreference == themePreference &&
        other.fontFamily == fontFamily &&
        other.fontScale == fontScale;
  }

  @override
  int get hashCode => Object.hash(
    unitSystem,
    baseUnit,
    showHiddenFiles,
    themePreference,
    fontFamily,
    fontScale,
  );
}
