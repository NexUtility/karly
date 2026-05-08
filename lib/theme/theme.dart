import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.accent,
      brightness: Brightness.light,
      surface: BrandColors.lightBg,
      onSurface: BrandColors.lightFg,
      primary: BrandColors.accent,
      onPrimary: BrandColors.accentForeground,
      outline: BrandColors.lightBorder,
      outlineVariant: BrandColors.lightBorderStrong,
      error: BrandColors.danger,
    );
    return _build(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.accent,
      brightness: Brightness.dark,
      surface: BrandColors.darkBg,
      surfaceContainerLow: BrandColors.darkElev,
      surfaceContainer: BrandColors.darkElev2,
      onSurface: BrandColors.darkFg,
      primary: BrandColors.accent,
      onPrimary: BrandColors.accentForeground,
      outline: BrandColors.darkBorder,
      outlineVariant: BrandColors.darkBorderStrong,
      error: BrandColors.danger,
    );
    return _build(scheme, Brightness.dark);
  }

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fgMuted = isDark ? BrandColors.darkFgMuted : BrandColors.lightFgMuted;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      brightness: brightness,
      textTheme: _textTheme(scheme.onSurface, fgMuted),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: scheme.outline),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: fgMuted, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: fgMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: scheme.outline),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: scheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary, size: 22);
          }
          return IconThemeData(color: fgMuted, size: 22);
        }),
        height: 64,
      ),
      dividerColor: scheme.outline,
      visualDensity: VisualDensity.standard,
    );
  }

  static TextTheme _textTheme(Color fg, Color fgMuted) {
    return TextTheme(
      displayLarge: TextStyle(
        color: fg,
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.0,
      ),
      headlineLarge: TextStyle(
        color: fg,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      headlineMedium: TextStyle(
        color: fg,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        color: fg,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        color: fg,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: fg,
        fontSize: 15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: fg,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: fgMuted,
        fontSize: 12.5,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: fg,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: fgMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
  }
}
