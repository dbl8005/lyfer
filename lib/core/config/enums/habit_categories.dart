import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class HabitCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color defaultColor;

  const HabitCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.defaultColor,
  });
}

// Define common habit categories
final List<HabitCategory> habitCategories = [
  HabitCategory(
    id: 'health',
    name: 'Health',
    icon: LineIcons.heartbeat,
    defaultColor: Colors.red.shade400,
  ),
  HabitCategory(
    id: 'fitness',
    name: 'Fitness',
    icon: LineIcons.dumbbell,
    defaultColor: Colors.orange.shade400,
  ),
  HabitCategory(
    id: 'nutrition',
    name: 'Nutrition',
    icon: LineIcons.apple,
    defaultColor: Colors.green.shade400,
  ),
  HabitCategory(
    id: 'mindfulness',
    name: 'Mindfulness',
    icon: LineIcons.brain,
    defaultColor: Colors.purple.shade400,
  ),
  HabitCategory(
    id: 'learning',
    name: 'Learning',
    icon: LineIcons.book,
    defaultColor: Colors.blue.shade400,
  ),
  HabitCategory(
    id: 'productivity',
    name: 'Productivity',
    icon: LineIcons.tasks,
    defaultColor: Colors.teal.shade400,
  ),
  HabitCategory(
    id: 'creativity',
    name: 'Creativity',
    icon: LineIcons.paintBrush,
    defaultColor: Colors.pink.shade400,
  ),
  HabitCategory(
    id: 'finance',
    name: 'Finance',
    icon: LineIcons.wallet,
    defaultColor: Colors.amber.shade400,
  ),
  HabitCategory(
    id: 'social',
    name: 'Social',
    icon: LineIcons.users,
    defaultColor: Colors.cyan.shade400,
  ),
  HabitCategory(
    id: 'other',
    name: 'Other',
    icon: LineIcons.starOfLife,
    defaultColor: Colors.grey.shade400,
  ),
];

// Helper function to find a category by id
HabitCategory? findCategoryById(String id) {
  try {
    return habitCategories.firstWhere((category) => category.id == id);
  } catch (e) {
    return null;
  }
}
