enum SizeUnitSystem { binary, decimal }

enum SizeBaseUnit { byte, bit }

enum AppThemePreference { system, light, dark }

class AppSettings {
  const AppSettings({
    this.unitSystem = SizeUnitSystem.binary,
    this.baseUnit = SizeBaseUnit.byte,
    this.showHiddenFiles = false,
    this.themePreference = AppThemePreference.system,
  });

  final SizeUnitSystem unitSystem;
  final SizeBaseUnit baseUnit;
  final bool showHiddenFiles;
  final AppThemePreference themePreference;

  AppSettings copyWith({
    SizeUnitSystem? unitSystem,
    SizeBaseUnit? baseUnit,
    bool? showHiddenFiles,
    AppThemePreference? themePreference,
  }) {
    return AppSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      baseUnit: baseUnit ?? this.baseUnit,
      showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
      themePreference: themePreference ?? this.themePreference,
    );
  }

  Map<String, Object> toJson() => {
    'unitSystem': unitSystem.name,
    'baseUnit': baseUnit.name,
    'showHiddenFiles': showHiddenFiles,
    'themePreference': themePreference.name,
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
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.unitSystem == unitSystem &&
        other.baseUnit == baseUnit &&
        other.showHiddenFiles == showHiddenFiles &&
        other.themePreference == themePreference;
  }

  @override
  int get hashCode =>
      Object.hash(unitSystem, baseUnit, showHiddenFiles, themePreference);
}
