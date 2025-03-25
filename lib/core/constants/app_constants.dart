import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;

  static const EdgeInsets paddingAllS = EdgeInsets.all(s);
  static const EdgeInsets paddingAllM = EdgeInsets.all(m);
  static const EdgeInsets paddingHorizontalM =
      EdgeInsets.symmetric(horizontal: m);
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: s);
  static const EdgeInsets paddingHorizS =
      EdgeInsets.symmetric(horizontal: 12, vertical: 2);
}

class AppFontSizes {
  static const double xs = 10.0;
  static const double s = 12.0;
  static const double m = 14.0;
  static const double l = 16.0;
  static const double xl = 20.0;
}

class AppBorderRadius {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
}

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
