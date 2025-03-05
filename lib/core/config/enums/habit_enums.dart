import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

enum DaySection {
  morning('Morning', LineIcons.coffee), // 5 AM - 11 AM
  noon('Noon', LineIcons.sun), // 11 AM - 5 PM
  evening('Evening', LineIcons.moon), // 5 PM - 11 PM
  allDay('All Day', LineIcons.clock); // 12 AM - 11 PM

  final String displayText;
  final IconData icon;

  const DaySection(this.displayText, this.icon);
}

enum Frequency {
  daily,
  weekly,
  monthly,
}

enum Reminder {
  none,
  notification,
  alarm,
}
