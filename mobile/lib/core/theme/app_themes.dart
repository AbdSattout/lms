import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes{
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

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.dark,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.dark),
      bodyMedium: TextStyle(color: AppColors.darkSoft),
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

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textDarkSoft,
      elevation: 0,
    ),
  );
}