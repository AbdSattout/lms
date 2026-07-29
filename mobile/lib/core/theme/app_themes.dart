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
        fontSize: 17, fontWeight: FontWeight.w700, color: primaryText,
      ),
      titleMedium: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w600, color: primaryText,
      ),
      bodyLarge: GoogleFonts.ibmPlexSansArabic(color: primaryText),
      bodyMedium: GoogleFonts.ibmPlexSansArabic(color: secondaryText),
      bodySmall: GoogleFonts.ibmPlexSansArabic(color: secondaryText),
      labelLarge: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w600, color: primaryText,
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
      titleTextStyle: GoogleFonts.lalezar(
        fontSize: 20,
        color: AppColors.dark,
      ),
    ),

    textTheme: _buildTextTheme(
      primaryText: AppColors.dark,
      secondaryText: AppColors.darkSoft,
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
  );
}