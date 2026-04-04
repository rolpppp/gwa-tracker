import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary: Dark Sage (action color — buttons, FAB, active states)
  static const Color primaryColor = Color(0xFF006D36);
  // Primary Container: Light Mint (tint/chip backgrounds)
  static const Color primaryContainer = Color(0xFF4ADE80);
  // Secondary: Muted Violet (accents)
  static const Color accentColor = Color(0xFF6B38D4);
  // Secondary Container: Soft Violet
  static const Color accentContainer = Color(0xFF8455EF);
  // On-Surface text (never pure black)
  static const Color onSurface = Color(0xFF191C1E);
  // Surface background
  static const Color surfaceColor = Color(0xFFF7F9FC);

  static ThemeData get lightTheme {
    final base = FlexThemeData.light(
      scheme: FlexScheme.jungle,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        defaultRadius: 24.0,
        elevatedButtonRadius: 16.0,
        inputDecoratorRadius: 16.0,
        fabRadius: 32.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryContainer,
        secondary: accentColor,
        secondaryContainer: accentContainer,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: onSurface,
      ),
      // Plus Jakarta Sans for headlines/titles, Be Vietnam Pro for body/labels
      textTheme: base.textTheme.copyWith(
        bodyLarge: GoogleFonts.beVietnamPro(fontSize: 16, height: 1.6, color: onSurface),
        bodyMedium: GoogleFonts.beVietnamPro(fontSize: 14, height: 1.6, color: onSurface),
        bodySmall: GoogleFonts.beVietnamPro(fontSize: 12, height: 1.6, color: Color(0xFF3D4A3E)),
        labelLarge: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.beVietnamPro(fontSize: 12),
        labelSmall: GoogleFonts.beVietnamPro(fontSize: 11),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = FlexThemeData.dark(
      scheme: FlexScheme.jungle,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        defaultRadius: 24.0,
        elevatedButtonRadius: 16.0,
        inputDecoratorRadius: 16.0,
        fabRadius: 32.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );

    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryContainer,
        secondary: accentColor,
        secondaryContainer: accentContainer,
        surface: Color(0xFF1F2937),
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      textTheme: base.textTheme.copyWith(
        bodyLarge: GoogleFonts.beVietnamPro(fontSize: 16, height: 1.6),
        bodyMedium: GoogleFonts.beVietnamPro(fontSize: 14, height: 1.6),
        bodySmall: GoogleFonts.beVietnamPro(fontSize: 12, height: 1.6),
        labelLarge: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.beVietnamPro(fontSize: 12),
        labelSmall: GoogleFonts.beVietnamPro(fontSize: 11),
      ),
    );
  }
}