import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryLight = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF8B83FF);
  static const Color accentLight = Color(0xFFFF6584);
  static const Color accentDark = Color(0xFFFF8FA3);

  static const Color backgroundLight = Color(0xFFF5F5FA);
  static const Color backgroundDark = Color(0xFF1A1A2E);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16213E);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF0F3460);

  static const Color textPrimaryLight = Color(0xFF2D2D3A);
  static const Color textPrimaryDark = Color(0xFFE8E8F0);

  static const Color textSecondaryLight = Color(0xFF6B6B80);
  static const Color textSecondaryDark = Color(0xFFA0A0B8);

  static const Color playerX = Color(0xFF6C63FF);
  static const Color playerO = Color(0xFFFF6584);

  static const Color winHighlight = Color(0xFF4CAF50);
  static const Color drawHighlight = Color(0xFFFF9800);

  static const Color gridLineLight = Color(0xFFD0D0E0);
  static const Color gridLineDark = Color(0xFF2A2A4A);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.accentLight,
        surface: AppColors.surfaceLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.accentDark,
        surface: AppColors.surfaceDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
