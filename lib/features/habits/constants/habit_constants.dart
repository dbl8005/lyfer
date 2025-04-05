import 'package:flutter/material.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';

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
}
