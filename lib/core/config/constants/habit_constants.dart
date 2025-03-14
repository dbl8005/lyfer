import 'package:flutter/material.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';

/// Constants used throughout the habits feature
class HabitsConstants {
  // Day sections in chronological order
  static const List<DaySection> sectionOrder = [
    DaySection.morning,
    DaySection.afternoon,
    DaySection.evening,
    DaySection.night,
    DaySection.allDay,
  ];

  // UI constants
  static const double sectionSpacing = 12.0;
  static const double habitTileSpacing = 4.0;
  static const double bottomPadding = 130.0;
  static const double sectionScrollOffset = 80.0;
  static const double sectionCornerRadius = 12.0;
  static const double daySelectCornerRadius = 16.0;

  // Animation constants
  static const Duration scrollAnimationDuration = Duration(milliseconds: 500);
  static const Curve scrollAnimationCurve = Curves.easeInOut;
}
