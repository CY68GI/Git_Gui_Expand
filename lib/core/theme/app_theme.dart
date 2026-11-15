import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color accent = Color(0xFF087C68);
  static const Color darkAccent = Color(0xFF43D4B4);

  static ThemeData light({String? fontFamily}) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
          surface: Colors.white,
        ).copyWith(
          primary: accent,
          onPrimary: Colors.white,
          onSurface: const Color(0xFF17211E),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFF7F9F8),
          surfaceContainer: const Color(0xFFEDF2EF),
          outline: const Color(0xFFC8D1CC),
          outlineVariant: const Color(0xFFDDE4E0),
        );
    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: const Color(0xFFF2F5F3),
      tooltipBackground: const Color(0xFF17211E),
      fontFamily: fontFamily,
    );
  }

  static ThemeData dark({String? fontFamily}) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: darkAccent,
          brightness: Brightness.dark,
          surface: const Color(0xFF171E1B),
        ).copyWith(
          primary: darkAccent,
          onPrimary: const Color(0xFF05241D),
          onSurface: const Color(0xFFE8EFEA),
          onSurfaceVariant: const Color(0xFFA9B8B1),
          surfaceContainerLowest: const Color(0xFF101513),
          surfaceContainerLow: const Color(0xFF1D2522),
          surfaceContainer: const Color(0xFF25302C),
          outline: const Color(0xFF52615A),
          outlineVariant: const Color(0xFF33413B),
          error: const Color(0xFFFFB4AB),
        );
    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: const Color(0xFF0C1110),
      tooltipBackground: const Color(0xFFE8EFEA),
      fontFamily: fontFamily,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color tooltipBackground,
    required String? fontFamily,
  }) {
    final tooltipForeground = tooltipBackground.computeLuminance() > 0.5
        ? const Color(0xFF17211E)
        : Colors.white;
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
          color: tooltipBackground,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(color: tooltipForeground, fontSize: 12),
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
