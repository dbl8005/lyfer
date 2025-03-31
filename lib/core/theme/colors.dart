import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF5571E0); // Modern blue
  static const Color secondary = Color(0xFF64DCCF); // Mint
  static const Color tertiary = Color(0xFFFFA26B); // Peach

  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF64B5F6);

  // Light Theme
  static const Color lightBackground = Color(0xFFF8F9FD);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF26315F);
  static const Color lightTextSecondary = Color(0xFF5E6687);
  static const Color lightDivider = Color(0xFFEBEFF5);
  static const Color lightInputBackground = Color(0xFFEEF0F7);
  static const Color lightCardBackground = Color(0xFFF8F9FD);
  static const Color lightCardShadow = Color(0xFFB0B7D2);

  // Dark Theme
  static const Color darkBackground = Color(0xFF12151D);
  static const Color darkSurface = Color(0xFF1C2030);
  static const Color darkTextPrimary = Color(0xFFE4E8F7);
  static const Color darkTextSecondary = Color(0xFF9AA1BC);
  static const Color darkDivider = Color(0xFF2D3349);
  static const Color darkInputBackground = Color(0xFF252A3D);
  static const Color darkCardBackground = Color(0xFF1C2030);
  static const Color darkCardShadow = Color(0xFF2D3349);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF7F8AE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF8CE5DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Task Priority Colors
  static const Color lowPriority = Color(0xFF8BC34A);
  static const Color mediumPriority = Color(0xFFFFB74D);
  static const Color highPriority = Color(0xFFF44336);
}
