import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand palette
  static const Color primaryLight = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF8B83FF);
  static const Color accentLight = Color(0xFFFF6584);
  static const Color accentDark = Color(0xFFFF8FA3);

  // Surfaces
  static const Color backgroundLight = Color(0xFFF0F0F8);
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF0F3460);

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textPrimaryDark = Color(0xFFEAEAF4);
  static const Color textSecondaryLight = Color(0xFF6B6B80);
  static const Color textSecondaryDark = Color(0xFF9090AA);

  // Players
  static const Color playerX = Color(0xFF6C63FF);
  static const Color playerO = Color(0xFFFF6584);

  // Status
  static const Color winColor = Color(0xFF00C853);
  static const Color drawColor = Color(0xFFFF9800);

  // Grid
  static const Color gridLight = Color(0xFFE0E0EE);
  static const Color gridDark = Color(0xFF252545);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryLight, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightBgGradient = LinearGradient(
    colors: [Color(0xFFF0F0F8), Color(0xFFE8E8F4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color textPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondaryLight;
  static Color surface(bool isDark) =>
      isDark ? surfaceDark : surfaceLight;
  static Color background(bool isDark) =>
      isDark ? backgroundDark : backgroundLight;
  static Color grid(bool isDark) =>
      isDark ? gridDark : gridLight;
  static Color primary(bool isDark) =>
      isDark ? primaryDark : primaryLight;
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
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
