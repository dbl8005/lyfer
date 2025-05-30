import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

enum DaySection {
  morning,
  afternoon, // Use afternoon consistently (not noon)
  evening,
  night,
  allDay; // Keep allDay section

  String get label => switch (this) {
        DaySection.morning => 'Morning',
        DaySection.afternoon => 'Afternoon',
        DaySection.evening => 'Evening',
        DaySection.night => 'Night',
        DaySection.allDay => 'All Day',
      };

  // Default time range for each section
  TimeOfDay get defaultStartTime => switch (this) {
        DaySection.morning => const TimeOfDay(hour: 6, minute: 0),
        DaySection.afternoon => const TimeOfDay(hour: 12, minute: 0),
        DaySection.evening => const TimeOfDay(hour: 17, minute: 0),
        DaySection.night => const TimeOfDay(hour: 20, minute: 0),
        DaySection.allDay => const TimeOfDay(hour: 0, minute: 0),
      };

  IconData get icon => switch (this) {
        DaySection.morning => LineIcons.sun,
        DaySection.afternoon => LineIcons.cloud,
        DaySection.evening => LineIcons.moon,
        DaySection.night => LineIcons.bed,
        DaySection.allDay => LineIcons.clock,
      };
}

enum Frequency {
  daily,
  weekly,
  monthly,
  yearly,
  custom; // Custom frequency for advanced users

  String get label => switch (this) {
        Frequency.daily => 'Daily',
        Frequency.weekly => 'Weekly',
        Frequency.monthly => 'Monthly',
        Frequency.yearly => 'Yearly',
        Frequency.custom => 'Custom',
      };
}

enum Reminder {
  none,
  notification,
  alarm;

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

enum Priority {
  none,
  low,
  medium,
  high,
  critical;

  String get label => switch (this) {
        Priority.none => 'None',
        Priority.low => 'Low',
        Priority.medium => 'Medium',
        Priority.high => 'High',
        Priority.critical => 'Critical',
      };

  Color getColor(BuildContext context) => switch (this) {
        Priority.none => Colors.grey,
        Priority.low => Colors.blue,
        Priority.medium => Colors.green,
        Priority.high => Colors.orange,
        Priority.critical => Colors.red,
      };

  IconData get icon => switch (this) {
        Priority.none => Icons.remove_circle_outline,
        Priority.low => Icons.keyboard_arrow_down,
        Priority.medium => Icons.remove,
        Priority.high => Icons.keyboard_arrow_up,
        Priority.critical => Icons.priority_high,
      };
}

enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get label => switch (this) {
        WeekDay.monday => 'Monday',
        WeekDay.tuesday => 'Tuesday',
        WeekDay.wednesday => 'Wednesday',
        WeekDay.thursday => 'Thursday',
        WeekDay.friday => 'Friday',
        WeekDay.saturday => 'Saturday',
        WeekDay.sunday => 'Sunday',
      };
  int get dayIndex => switch (this) {
        WeekDay.monday => 0,
        WeekDay.tuesday => 1,
        WeekDay.wednesday => 2,
        WeekDay.thursday => 3,
        WeekDay.friday => 4,
        WeekDay.saturday => 5,
        WeekDay.sunday => 6,
      };
}
