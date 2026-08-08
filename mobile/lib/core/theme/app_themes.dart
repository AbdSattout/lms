import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppThemes {
  static TextTheme _buildTextTheme({
    required Color primaryText,
    required Color secondaryText,
  }) {
    final base = GoogleFonts.ibmPlexSansArabicTextTheme();

    return base.copyWith(
      displayLarge: GoogleFonts.lalezar(fontSize: 34, color: primaryText),
      displayMedium: GoogleFonts.lalezar(fontSize: 28, color: primaryText),
      displaySmall: GoogleFonts.lalezar(fontSize: 24, color: primaryText),
      headlineLarge: GoogleFonts.lalezar(fontSize: 22, color: primaryText),
      headlineMedium: GoogleFonts.lalezar(fontSize: 20, color: primaryText),
      headlineSmall: GoogleFonts.lalezar(fontSize: 18, color: primaryText),
      titleLarge: GoogleFonts.ibmPlexSansArabic(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      titleMedium: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: GoogleFonts.ibmPlexSansArabic(color: primaryText),
      bodyMedium: GoogleFonts.ibmPlexSansArabic(color: secondaryText),
      bodySmall: GoogleFonts.ibmPlexSansArabic(color: secondaryText),
      labelLarge: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
    );
  }

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.pink,
      surface: AppColors.surface,
    ),

    cardColor: AppColors.surface,

    dividerColor: AppColors.border,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.dark,
      elevation: 0,
      titleTextStyle: GoogleFonts.lalezar(fontSize: 20, color: AppColors.dark),
    ),

    textTheme: _buildTextTheme(
      primaryText: AppColors.dark,
      secondaryText: AppColors.darkSoft,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.pink,
      surface: AppColors.surfaceDark,
    ),

    cardColor: const Color(0xff1F2937),

    dividerColor: const Color(0xff374151),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textDarkSoft,
      elevation: 0,
      titleTextStyle: GoogleFonts.lalezar(
        fontSize: 20,
        color: AppColors.textDark,
      ),
    ),

    textTheme: _buildTextTheme(
      primaryText: AppColors.textDark,
      secondaryText: AppColors.textDarkSoft,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xff111827),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff374151)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff374151)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
