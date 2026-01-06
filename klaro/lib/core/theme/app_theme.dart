import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // The "Matcha/Sage" Primary Color
  static const Color primaryColor = Color(0xFF4ADE80); 
  // The "Purple" Accent (for the FAB)
  static const Color accentColor = Color(0xFF8B5CF6);
  // The "Navy" Text/Active Color
  static const Color textDark = Color(0xFF1A1F36);

  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.jungle, // A green-based starting point
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        // Make everything rounded (Cute UI)
        defaultRadius: 24.0, 
        elevatedButtonRadius: 16.0,
        inputDecoratorRadius: 16.0,
        fabRadius: 32.0, 
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily, // Modern Sans Serif
    ).copyWith(
      // Custom overrides
      scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Soft Blue-Grey
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return FlexThemeData.dark(
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
      fontFamily: GoogleFonts.poppins().fontFamily,
    ).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: Color(0xFF1F2937),
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
    );
  }
}