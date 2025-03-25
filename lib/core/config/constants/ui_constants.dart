import 'package:flutter/material.dart';

/// Consolidated UI constants used throughout the app for consistent styling
class UIConstants {
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color googleSignInColor = Colors.red;

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Spacing
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  static const double defaultPadding = 16.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 20.0;
  static const double extraLargeSpacing = 30.0;
  static const double formFieldSpacing = 20.0;

  // Common EdgeInsets
  static const EdgeInsets paddingAllS = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingAllM = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingHorizontalM =
      EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingVerticalS =
      EdgeInsets.symmetric(vertical: spacing8);

  // Radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusExtraLarge = 24;

  // Animations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Shadows
  static List<BoxShadow> smallShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> largeShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Button sizes
  static const Size defaultButtonSize = Size(200, 60);

  // Icon sizes
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 30.0;

  // Loading indicators
  static const double defaultLoadingSize = 24.0;
  static const String loadingHabitsLabel = 'Loading habits';

  // Error handling
  static const String errorPrefix = 'Failed to load habits: ';

  // Semantics labels
  static const String habitsScreenLabel = 'Habits screen';
}
