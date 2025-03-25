import 'package:flutter/material.dart';
import 'package:lyfer/core/config/constants/ui_constants.dart';

/// App theme configuration
class AppTheme {
  // Light theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: UIConstants.primaryColor,
    colorScheme: ColorScheme.light(primary: UIConstants.primaryColor),
    textTheme: TextTheme(
      headlineLarge: UIConstants.headingStyle,
      headlineMedium: UIConstants.subheadingStyle,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: UIConstants.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    primaryColor: UIConstants.primaryColor,
    colorScheme: ColorScheme.dark(primary: UIConstants.primaryColor),
    textTheme: TextTheme(
      headlineLarge: UIConstants.headingStyle.copyWith(color: Colors.white),
      headlineMedium: UIConstants.subheadingStyle.copyWith(color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: UIConstants.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
      ),
    ),
  );
}
