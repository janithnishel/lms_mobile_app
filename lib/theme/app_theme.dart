import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

// Helper function to create common theme properties
ButtonStyle _createButtonStyle(Color background, Color foreground) {
  return ElevatedButton.styleFrom(
    backgroundColor: background,
    foregroundColor: foreground,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  );
}

InputDecorationTheme _createInputDecorationTheme(Color borderColor) {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: borderColor),
    ),
  );
}

// Create base theme with common properties
ThemeData _createBaseTheme(Brightness brightness, AppColorsTheme colors) {
  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(
      brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme
    ),

    // Basic Colors
    primaryColor: colors.primary,
    scaffoldBackgroundColor: colors.background,

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
    ),

    // Button Styles
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _createButtonStyle(colors.primary, colors.primaryForeground),
    ),

    // Input Field Styles
    inputDecorationTheme: _createInputDecorationTheme(colors.border),

    // Customize the ColorScheme
    colorScheme: brightness == Brightness.light
        ? ColorScheme.light(
            primary: colors.primary,
            secondary: colors.secondary,
            surface: colors.background,
            error: colors.destructive,
            background: colors.background,
            onBackground: colors.foreground,
          )
        : ColorScheme.dark(
            primary: colors.primary,
            secondary: colors.secondary,
            surface: colors.background,
            error: colors.destructive,
            background: colors.background,
            onBackground: colors.foreground,
          ),
  );
}

// Wrapper class for theme colors to avoid duplication
class AppColorsTheme {
  final Color background;
  final Color foreground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color destructive;
  final Color border;
  final Color ring;

  const AppColorsTheme({
    required this.background,
    required this.foreground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.destructive,
    required this.border,
    required this.ring,
  });

  // Light theme colors
  static const light = AppColorsTheme(
    background: AppColors.lightBackground,
    foreground: AppColors.lightForeground,
    primary: AppColors.lightPrimary,
    primaryForeground: AppColors.lightPrimaryForeground,
    secondary: AppColors.lightSecondary,
    destructive: AppColors.lightDestructive,
    border: AppColors.lightBorder,
    ring: AppColors.lightRing,
  );

  // Dark theme colors
  static const dark = AppColorsTheme(
    background: AppColors.darkBackground,
    foreground: AppColors.darkForeground,
    primary: AppColors.darkPrimary,
    primaryForeground: AppColors.darkPrimaryForeground,
    secondary: AppColors.darkSecondary,
    destructive: AppColors.darkDestructive,
    border: AppColors.darkBorder,
    ring: AppColors.darkRing,
  );
}

// Final theme objects using helper functions
final lightTheme = _createBaseTheme(Brightness.light, AppColorsTheme.light);
final darkTheme = _createBaseTheme(Brightness.dark, AppColorsTheme.dark);
