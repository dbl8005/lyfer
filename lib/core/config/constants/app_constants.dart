import 'package:flutter/material.dart';

/// App-wide constants that aren't UI-specific
class AppConstants {
  // App information
  static const String appName = 'Lyfer';
  static const String appVersion = '1.0.0';

  // Default values
  static const int defaultAnimationDurationMs = 300;
  static const int defaultTimeoutSeconds = 30;

  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableReminders = true;
}

/// Task-related constants used throughout the app
class AppTaskColors {
  // Task due date colors
  static const Color overdue = Colors.red;
  static const Color dueToday = Colors.orange;
  static const Color dueSoon = Colors.amber;
  static const Color normal = Colors.green;

  // Task status colors
  static const Color completed = Colors.green;
  static const Color pending = Colors.grey;
}
