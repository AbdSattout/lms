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
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,

      secondary: AppColors.lavender,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lavenderLight,
      onSecondaryContainer: AppColors.lavender,

      tertiary: AppColors.gold,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.goldLight,
      onTertiaryContainer: Color(0xff92400E),

      surface: AppColors.surface,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.surfaceVariant,
      surfaceContainer: AppColors.surfaceVariant,
      surfaceContainerHigh: Color(0xffE8EDF3),
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurface: AppColors.dark,
      onSurfaceVariant: AppColors.darkSoft,

      outline: AppColors.border,
      outlineVariant: Color(0xffE8EDF3),

      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: Color(0xffB91C1C),
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

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.dark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
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
      primary: Color(0xff60A5FA),
      onPrimary: Color(0xff1E3A5F),
      primaryContainer: Color(0xff1E3A5F),
      onPrimaryContainer: Color(0xffDBEAFE),

      secondary: Color(0xffA78BFA),
      onSecondary: Color(0xff3B2F5E),
      secondaryContainer: Color(0xff3B2F5E),
      onSecondaryContainer: Color(0xffEDE9FE),

      tertiary: Color(0xffFBBF24),
      onTertiary: Color(0xff78350F),
      tertiaryContainer: Color(0xff78350F),
      onTertiaryContainer: Color(0xffFEF3C7),

      surface: AppColors.surfaceDark,
      surfaceContainerLowest: Color(0xff1A2332),
      surfaceContainerLow: AppColors.surfaceDark,
      surfaceContainer: AppColors.surfaceDark,
      surfaceContainerHigh: Color(0xff293548),
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurface: AppColors.textDark,
      onSurfaceVariant: AppColors.textDarkSoft,

      outline: AppColors.borderDark,
      outlineVariant: Color(0xff3B4A5F),

      error: Color(0xffF87171),
      onError: Color(0xff450A0A),
      errorContainer: Color(0xff450A0A),
      onErrorContainer: Color(0xffFEE2E2),
    ),

    cardColor: AppColors.surfaceDark,
    dividerColor: AppColors.borderDark,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      titleTextStyle: GoogleFonts.lalezar(
        fontSize: 20,
        color: AppColors.textDark,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff60A5FA),
        foregroundColor: const Color(0xff1E3A5F),
        elevation: 0,
        minimumSize: const Size(0, 48), // FIXED: Changed double.infinity to 0
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff60A5FA),
        side: const BorderSide(color: AppColors.borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xff60A5FA),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariantDark.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff60A5FA), width: 1.5),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceVariantDark,
      contentTextStyle: const TextStyle(color: AppColors.textDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),

    textTheme: _buildTextTheme(
      primaryText: AppColors.textDark,
      secondaryText: AppColors.textDarkSoft,
    ),
  );
}