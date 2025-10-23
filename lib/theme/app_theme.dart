import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

//ThemeData Objects

final lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  // set the Font
  textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),

  // Basic Colors
  primaryColor: AppColors.lightPrimary, //se the AppColors
  scaffoldBackgroundColor: AppColors.lightBackground,

  // App Bar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.lightForeground,
  ),

  // Button Styles
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightPrimaryForeground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
  ),

  // Input Field Styles
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: AppColors.lightBorder),
    ),
  ),

  // Customize the ColorScheme
  colorScheme: ColorScheme.light(
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
    surface: AppColors.lightBackground,
    error: AppColors.lightDestructive,
    background: AppColors.lightBackground,
    onBackground: AppColors.lightForeground,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),

  // Basic Colors
  primaryColor: AppColors.darkPrimary, //use the AppColors
  scaffoldBackgroundColor: AppColors.darkBackground,

  // App Bar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkForeground,
  ),

  // Button Styles
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkPrimaryForeground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
  ),

  // Input Field Styles
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: AppColors.darkBorder),
    ),
  ),

  // Customize the ColorScheme
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    surface: AppColors.darkBackground,
    error: AppColors.darkDestructive,
    background: AppColors.darkBackground,
    onBackground: AppColors.darkForeground,
  ),
);
