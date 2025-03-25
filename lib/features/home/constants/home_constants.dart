import 'package:flutter/material.dart';

/// Constants related to the home screen and navigation
class HomeConstants {
  // Section titles for each tab
  static const List<String> sectionTitles = [
    'Dashboard',
    'Habits',
    'Tasks',
    'Settings',
  ];

  // Icons for each tab in the bottom navigation
  static const List<IconData> navigationIcons = [
    Icons.dashboard,
    Icons.checklist,
    Icons.task,
    Icons.settings,
  ];

  // Section indices for navigation
  static const int dashboardIndex = 0;
  static const int habitsIndex = 1;
  static const int tasksIndex = 2;
  static const int settingsIndex = 3;
}
