import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

enum CategoryType {
  habit,
  task,
  both, // Categories that apply to both features
}

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color defaultColor;
  final CategoryType type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.defaultColor,
    this.type = CategoryType.both, // Default to usable in both contexts
  });
}

// Define app-wide categories
final List<CategoryModel> appCategories = [
  CategoryModel(
    id: 'health',
    name: 'Health',
    icon: LineIcons.heartbeat,
    defaultColor: Colors.red.shade400,
  ),
  CategoryModel(
    id: 'fitness',
    name: 'Fitness',
    icon: LineIcons.dumbbell,
    defaultColor: Colors.orange.shade400,
  ),
  CategoryModel(
    id: 'nutrition',
    name: 'Nutrition',
    icon: LineIcons.apple,
    defaultColor: Colors.green.shade400,
  ),
  CategoryModel(
    id: 'mindfulness',
    name: 'Mindfulness',
    icon: LineIcons.brain,
    defaultColor: Colors.purple.shade400,
  ),
  CategoryModel(
    id: 'learning',
    name: 'Learning',
    icon: LineIcons.book,
    defaultColor: Colors.blue.shade400,
  ),
  CategoryModel(
    id: 'productivity',
    name: 'Productivity',
    icon: LineIcons.tasks,
    defaultColor: Colors.teal.shade400,
  ),
  CategoryModel(
    id: 'creativity',
    name: 'Creativity',
    icon: LineIcons.paintBrush,
    defaultColor: Colors.pink.shade400,
  ),
  CategoryModel(
    id: 'finance',
    name: 'Finance',
    icon: LineIcons.wallet,
    defaultColor: Colors.amber.shade400,
  ),
  CategoryModel(
    id: 'social',
    name: 'Social',
    icon: LineIcons.users,
    defaultColor: Colors.cyan.shade400,
  ),
  CategoryModel(
    id: 'travel',
    name: 'Travel',
    icon: LineIcons.plane,
    defaultColor: Colors.indigo.shade400,
  ),
  CategoryModel(
    id: 'work',
    name: 'Work',
    icon: LineIcons.briefcase,
    defaultColor: Colors.blue.shade400,
  ),
  CategoryModel(
    id: 'home',
    name: 'Home',
    icon: LineIcons.home,
    defaultColor: Colors.brown.shade400,
  ),
  CategoryModel(
    id: 'shopping',
    name: 'Shopping',
    icon: LineIcons.shoppingBag,
    defaultColor: Colors.purple.shade400,
  ),
  CategoryModel(
    id: 'entertainment',
    name: 'Entertainment',
    icon: LineIcons.film,
    defaultColor: Colors.yellow.shade400,
  ),
  CategoryModel(
    id: 'self-care',
    name: 'Self-Care',
    icon: LineIcons.faceBlowingAKiss,
    defaultColor: Colors.pink.shade400,
  ),
  CategoryModel(
    id: 'family',
    name: 'Family',
    icon: LineIcons.userFriends,
    defaultColor: Colors.teal.shade400,
  ),
  CategoryModel(
    id: 'pets',
    name: 'Pets',
    icon: LineIcons.paw,
    defaultColor: Colors.orange.shade400,
  ),
  CategoryModel(
    id: 'hobbies',
    name: 'Hobbies',
    icon: LineIcons.gamepad,
    defaultColor: Colors.green.shade400,
  ),
  CategoryModel(
    id: 'events',
    name: 'Events',
    icon: LineIcons.calendar,
    defaultColor: Colors.blue.shade400,
  ),
  CategoryModel(
    id: 'other',
    name: 'Other',
    icon: LineIcons.starOfLife,
    defaultColor: Colors.grey.shade400,
  ),
];

// Helper functions
CategoryModel? findCategoryById(String id) {
  try {
    return appCategories.firstWhere((category) => category.id == id);
  } catch (e) {
    return null;
  }
}

// Get categories filtered by type
List<CategoryModel> getCategoriesByType(CategoryType type) {
  return appCategories
      .where((category) =>
          category.type == type || category.type == CategoryType.both)
      .toList();
}
