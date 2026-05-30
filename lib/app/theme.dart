import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SW {
  static const primary = Color(0xFF005394);
  static const primaryContainer = Color(0xFF2B6CB0);
  static const onPrimary = Colors.white;

  static const secondary = Color(0xFF0A6C44);
  static const secondaryContainer = Color(0xFF9FF5C1);
  static const onSecondaryContainer = Color(0xFF167249);

  static const tertiary = Color(0xFFA3151C);
  static const tertiaryContainer = Color(0xFFC63131);
  static const onTertiary = Colors.white;

  static const background = Color(0xFFF9F9FF);
  static const surface = Color(0xFFF9F9FF);
  static const surfaceContainerLowest = Colors.white;
  static const surfaceContainerLow = Color(0xFFF1F3FF);
  static const surfaceContainer = Color(0xFFE8EEFF);
  static const surfaceContainerHigh = Color(0xFFE3E8F9);
  static const surfaceContainerHighest = Color(0xFFDDE2F3);

  static const onSurface = Color(0xFF161C27);
  static const onSurfaceVariant = Color(0xFF414750);
  static const outline = Color(0xFF727782);
  static const outlineVariant = Color(0xFFC1C7D2);
}

ThemeData buildSafeWearTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
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
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: SW.surface,
      onSurface: SW.onSurface,
      onSurfaceVariant: SW.onSurfaceVariant,
      outline: SW.outline,
      outlineVariant: SW.outlineVariant,
      inverseSurface: Color(0xFF2A303D),
      onInverseSurface: Color(0xFFECF0FF),
      inversePrimary: Color(0xFFA2C9FF),
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
        textStyle: GoogleFonts.manrope(
            fontSize: 16, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SW.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SW.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SW.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SW.primary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: SW.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
