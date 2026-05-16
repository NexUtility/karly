import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: BrandColors.accentLight,
      onPrimary: BrandColors.accentForegroundLight,
      secondary: BrandColors.lightFg,
      onSecondary: BrandColors.lightBg,
      tertiary: BrandColors.posLight,
      onTertiary: BrandColors.lightBg,
      error: BrandColors.negLight,
      onError: Colors.white,
      surface: BrandColors.lightBg,
      onSurface: BrandColors.lightFg,
      surfaceContainerLowest: BrandColors.lightBg,
      surfaceContainerLow: BrandColors.lightElev,
      surfaceContainer: BrandColors.lightElev,
      surfaceContainerHigh: BrandColors.lightElev2,
      surfaceContainerHighest: BrandColors.lightElev2,
      outline: BrandColors.lightBorder,
      outlineVariant: BrandColors.lightBorderStrong,
    );
    return _build(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: BrandColors.accentDark,
      onPrimary: BrandColors.accentForegroundDark,
      secondary: BrandColors.darkFg,
      onSecondary: BrandColors.darkBg,
      tertiary: BrandColors.posDark,
      onTertiary: BrandColors.darkBg,
      error: BrandColors.negDark,
      onError: BrandColors.darkBg,
      surface: BrandColors.darkBg,
      onSurface: BrandColors.darkFg,
      surfaceContainerLowest: BrandColors.darkBg,
      surfaceContainerLow: BrandColors.darkElev,
      surfaceContainer: BrandColors.darkElev,
      surfaceContainerHigh: BrandColors.darkElev2,
      surfaceContainerHighest: BrandColors.darkElev2,
      outline: BrandColors.darkBorder,
      outlineVariant: BrandColors.darkBorderStrong,
    );
    return _build(scheme, Brightness.dark);
  }

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fg = isDark ? BrandColors.darkFg : BrandColors.lightFg;
    final fgMuted = isDark ? BrandColors.darkFgMuted : BrandColors.lightFgMuted;
    final border = isDark ? BrandColors.darkBorder : BrandColors.lightBorder;
    final panel = isDark ? BrandColors.darkElev : BrandColors.lightElev;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      brightness: brightness,
      textTheme: _textTheme(fg, fgMuted),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: fg,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.45,
        ),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 8,
        ),
        // Underline only — matches the Calm Field atom.
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: fg, width: 1.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: fgMuted,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        floatingLabelStyle: TextStyle(
          color: fgMuted,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        hintStyle: TextStyle(color: fgMuted.withValues(alpha: 0.6)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.15,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          side: BorderSide(color: border),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.15,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: fgMuted,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.05,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? fg : fgMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.05,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: fg, size: 22);
          }
          return IconThemeData(color: fgMuted, size: 22);
        }),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      visualDensity: VisualDensity.standard,
    );
  }

  static TextTheme _textTheme(Color fg, Color fgMuted) {
    return TextTheme(
      displayLarge: TextStyle(
        color: fg,
        fontSize: 56,
        fontWeight: FontWeight.w500,
        letterSpacing: -2.5,
        height: 1,
      ),
      headlineLarge: TextStyle(
        color: fg,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.98,
        height: 1.1,
      ),
      headlineMedium: TextStyle(
        color: fg,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.66,
      ),
      titleLarge: TextStyle(
        color: fg,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.45,
      ),
      titleMedium: TextStyle(
        color: fg,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.15,
      ),
      bodyLarge: TextStyle(
        color: fg,
        fontSize: 15,
        height: 1.5,
        letterSpacing: -0.075,
      ),
      bodyMedium: TextStyle(
        color: fg,
        fontSize: 14,
        height: 1.45,
        letterSpacing: -0.07,
      ),
      bodySmall: TextStyle(
        color: fgMuted,
        fontSize: 12.5,
        height: 1.4,
        letterSpacing: -0.0625,
      ),
      labelLarge: TextStyle(
        color: fg,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.07,
      ),
      labelMedium: TextStyle(
        color: fgMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.06,
      ),
    );
  }
}
