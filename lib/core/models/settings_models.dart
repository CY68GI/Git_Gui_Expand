enum SizeUnitSystem { binary, decimal }

enum SizeBaseUnit { byte, bit }

enum AppThemePreference { system, light, dark }

class AppSettings {
  const AppSettings({
    this.unitSystem = SizeUnitSystem.binary,
    this.baseUnit = SizeBaseUnit.byte,
    this.showHiddenFiles = false,
    this.themePreference = AppThemePreference.system,
    this.fontFamily = '',
  });

  final SizeUnitSystem unitSystem;
  final SizeBaseUnit baseUnit;
  final bool showHiddenFiles;
  final AppThemePreference themePreference;
  final String fontFamily;

  AppSettings copyWith({
    SizeUnitSystem? unitSystem,
    SizeBaseUnit? baseUnit,
    bool? showHiddenFiles,
    AppThemePreference? themePreference,
    String? fontFamily,
  }) {
    return AppSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      baseUnit: baseUnit ?? this.baseUnit,
      showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
      themePreference: themePreference ?? this.themePreference,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  Map<String, Object> toJson() => {
    'unitSystem': unitSystem.name,
    'baseUnit': baseUnit.name,
    'showHiddenFiles': showHiddenFiles,
    'themePreference': themePreference.name,
    'fontFamily': fontFamily,
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
      fontFamily: (json['fontFamily'] as String? ?? '').trim(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.unitSystem == unitSystem &&
        other.baseUnit == baseUnit &&
        other.showHiddenFiles == showHiddenFiles &&
        other.themePreference == themePreference &&
        other.fontFamily == fontFamily;
  }

  @override
  int get hashCode => Object.hash(
    unitSystem,
    baseUnit,
    showHiddenFiles,
    themePreference,
    fontFamily,
  );
}
