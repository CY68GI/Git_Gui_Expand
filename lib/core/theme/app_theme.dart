import 'package:flutter/material.dart';

import '../models/settings_models.dart';

class AppColorPalette {
  const AppColorPalette({required this.lightSeed, required this.darkAccent});

  final Color lightSeed;
  final Color darkAccent;
}

class AppTheme {
  const AppTheme._();

  static AppColorPalette palette(AppColorSchemePreference preference) {
    return switch (preference) {
      AppColorSchemePreference.emerald => const AppColorPalette(
        lightSeed: Color(0xFF087C68),
        darkAccent: Color(0xFF43D4B4),
      ),
      AppColorSchemePreference.ocean => const AppColorPalette(
        lightSeed: Color(0xFF1769AA),
        darkAccent: Color(0xFF6CC7FF),
      ),
      AppColorSchemePreference.violet => const AppColorPalette(
        lightSeed: Color(0xFF6549C8),
        darkAccent: Color(0xFFB9A7FF),
      ),
      AppColorSchemePreference.amber => const AppColorPalette(
        lightSeed: Color(0xFF946200),
        darkAccent: Color(0xFFFFC857),
      ),
      AppColorSchemePreference.rose => const AppColorPalette(
        lightSeed: Color(0xFFB43D62),
        darkAccent: Color(0xFFFF9BB4),
      ),
    };
  }

  static ThemeData light({
    String? fontFamily,
    AppColorSchemePreference colorScheme = AppColorSchemePreference.emerald,
  }) {
    final palette = AppTheme.palette(colorScheme);
    final generated = ColorScheme.fromSeed(
      seedColor: palette.lightSeed,
      brightness: Brightness.light,
    );
    final scheme = generated.copyWith(
      primary: palette.lightSeed,
      onPrimary: Colors.white,
      surface: Colors.white,
      surfaceContainerLowest: Colors.white,
    );
    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: scheme.surfaceContainerLow,
      fontFamily: fontFamily,
    );
  }

  static ThemeData dark({
    String? fontFamily,
    AppColorSchemePreference colorScheme = AppColorSchemePreference.emerald,
  }) {
    final palette = AppTheme.palette(colorScheme);
    final generated = ColorScheme.fromSeed(
      seedColor: palette.darkAccent,
      brightness: Brightness.dark,
    );
    final scheme = generated.copyWith(primary: palette.darkAccent);
    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: scheme.surfaceContainerLowest,
      fontFamily: fontFamily,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required String? fontFamily,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: fontFamily,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.13,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 13, height: 1.45),
        labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ).apply(fontFamily: fontFamily),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(color: scheme.onInverseSurface, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.all(18),
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
        showCloseIcon: true,
        closeIconColor: scheme.onInverseSurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          scheme.onSurfaceVariant.withValues(alpha: 0.35),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.28),
        selectionHandleColor: scheme.primary,
      ),
    );
  }
}
