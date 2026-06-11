import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SafeWear color tokens. All UI reads colors through these getters, so
/// flipping [isDark] re-themes the entire app (the root widget rebuilds the
/// tree when the setting changes).
class SW {
  static bool isDark = false;

  // ── Brand ──
  static Color get primary =>
      isDark ? const Color(0xFF5B9BD8) : const Color(0xFF005394);
  static Color get primaryContainer => const Color(0xFF2B6CB0);
  static Color get onPrimary => Colors.white;

  static Color get secondary =>
      isDark ? const Color(0xFF34C08B) : const Color(0xFF0A6C44);
  static Color get secondaryContainer =>
      isDark ? const Color(0xFF14352A) : const Color(0xFF9FF5C1);
  static Color get onSecondaryContainer =>
      isDark ? const Color(0xFF9FF5C1) : const Color(0xFF167249);

  static Color get tertiary =>
      isDark ? const Color(0xFFE25555) : const Color(0xFFA3151C);
  static Color get tertiaryContainer => const Color(0xFFC63131);
  static Color get onTertiary => Colors.white;

  // ── Surfaces ──
  static Color get background =>
      isDark ? const Color(0xFF0F1218) : const Color(0xFFF9F9FF);
  static Color get surface =>
      isDark ? const Color(0xFF0F1218) : const Color(0xFFF9F9FF);
  static Color get surfaceContainerLowest =>
      isDark ? const Color(0xFF171C26) : Colors.white;
  static Color get surfaceContainerLow =>
      isDark ? const Color(0xFF1B212D) : const Color(0xFFF1F3FF);
  static Color get surfaceContainer =>
      isDark ? const Color(0xFF202734) : const Color(0xFFE8EEFF);
  static Color get surfaceContainerHigh =>
      isDark ? const Color(0xFF26303F) : const Color(0xFFE3E8F9);
  static Color get surfaceContainerHighest =>
      isDark ? const Color(0xFF2C374A) : const Color(0xFFDDE2F3);

  // ── Content ──
  static Color get onSurface =>
      isDark ? const Color(0xFFE7EAF3) : const Color(0xFF161C27);
  static Color get onSurfaceVariant =>
      isDark ? const Color(0xFFA8AFBD) : const Color(0xFF414750);
  static Color get outline =>
      isDark ? const Color(0xFF6A7180) : const Color(0xFF727782);
  static Color get outlineVariant =>
      isDark ? const Color(0xFF353D4C) : const Color(0xFFC1C7D2);
}

ThemeData buildSafeWearTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: SW.isDark ? Brightness.dark : Brightness.light,
      primary: SW.primary,
      onPrimary: SW.onPrimary,
      primaryContainer: SW.primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: SW.secondary,
      onSecondary: Colors.white,
      secondaryContainer: SW.secondaryContainer,
      onSecondaryContainer: SW.onSecondaryContainer,
      tertiary: SW.tertiary,
      onTertiary: SW.onTertiary,
      tertiaryContainer: SW.tertiaryContainer,
      onTertiaryContainer: Colors.white,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF93000A),
      surface: SW.surface,
      onSurface: SW.onSurface,
      onSurfaceVariant: SW.onSurfaceVariant,
      outline: SW.outline,
      outlineVariant: SW.outlineVariant,
      inverseSurface:
          SW.isDark ? const Color(0xFFECF0FF) : const Color(0xFF2A303D),
      onInverseSurface:
          SW.isDark ? const Color(0xFF2A303D) : const Color(0xFFECF0FF),
      inversePrimary: const Color(0xFFA2C9FF),
      surfaceTint: SW.primary,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: SW.background,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.manrope(
          fontSize: 57, fontWeight: FontWeight.w800, color: SW.onSurface),
      displayMedium: GoogleFonts.manrope(
          fontSize: 45, fontWeight: FontWeight.w800, color: SW.onSurface),
      headlineLarge: GoogleFonts.manrope(
          fontSize: 32, fontWeight: FontWeight.w800, color: SW.onSurface),
      headlineMedium: GoogleFonts.manrope(
          fontSize: 26, fontWeight: FontWeight.w700, color: SW.onSurface),
      headlineSmall: GoogleFonts.manrope(
          fontSize: 22, fontWeight: FontWeight.w700, color: SW.onSurface),
      titleLarge: GoogleFonts.manrope(
          fontSize: 20, fontWeight: FontWeight.w700, color: SW.onSurface),
      titleMedium: GoogleFonts.manrope(
          fontSize: 16, fontWeight: FontWeight.w600, color: SW.onSurface),
      titleSmall: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w600, color: SW.onSurface),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: SW.onSurface),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: SW.onSurface),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: SW.onSurfaceVariant),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: SW.onSurface),
      labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: SW.onSurfaceVariant),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: SW.surface.withAlpha(204),
      surfaceTintColor: Colors.transparent,
      foregroundColor: SW.onSurface,
      elevation: 0,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: SW.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SW.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: const StadiumBorder(),
        textStyle:
            GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SW.surfaceContainerLow,
      labelStyle: GoogleFonts.inter(color: SW.onSurfaceVariant),
      hintStyle: GoogleFonts.inter(color: SW.outline),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: SW.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: SW.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: SW.primary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: SW.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
