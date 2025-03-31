import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

enum TaskCategory {
  work(LineIcons.briefcase, Colors.blue, 'Work'),
  personal(LineIcons.user, Colors.green, 'Personal'),
  health(LineIcons.heartbeat, Colors.red, 'Health'),
  shopping(LineIcons.shoppingBag, Colors.purple, 'Shopping'),
  education(LineIcons.graduationCap, Colors.amber, 'Education'),
  finance(LineIcons.coins, Colors.orange, 'Finance'),
  social(LineIcons.users, Colors.cyan, 'Social'),
  other(LineIcons.question, Colors.grey, 'Other');

  final IconData icon;
  final Color defaultColor;
  final String label;

  const TaskCategory(this.icon, this.defaultColor, this.label);
}

enum TaskPriority {
  none(LineIcons.minus, Colors.grey, 'None'),
  low(LineIcons.arrowDown, Colors.blue, 'Low'),
  medium(LineIcons.minus, Colors.yellow, 'Medium'),
  high(LineIcons.arrowUp, Colors.orange, 'High'),
  urgent(LineIcons.exclamation, Colors.red, 'Urgent');

  final IconData icon;
  final Color color;
  final String label;

  const TaskPriority(this.icon, this.color, this.label);

  Color getColor(BuildContext context) {
    return color;
  }
}
