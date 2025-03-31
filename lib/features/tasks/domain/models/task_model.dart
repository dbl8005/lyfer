import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lyfer/core/shared/models/category_model.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool isCompleted;
  final String categoryId; // Keeping consistent with HabitModel
  final Priority priority; // Using the shared Priority enum
  final Color? color;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    this.categoryId = 'other',
    this.priority = Priority.none,
    this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? categoryId, // Fixed parameter type
    Priority? priority, // Fixed parameter type
    Color? color,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId, // Fixed field name
      priority: priority ?? this.priority, // Fixed field name
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isCompleted': isCompleted,
      'categoryId': categoryId,
      'priority': priority.index,
      'color': color?.value,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json, {String? docId}) {
    // Use document ID if provided, otherwise use ID from json
    final id = docId ?? json['id'];

    return Task(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      isCompleted: json['isCompleted'] ?? false,
      categoryId: json['categoryId'] ?? 'other',
      priority: json['priority'] != null
          ? Priority.values[json['priority'] as int]
          : Priority.none,
      color: json['color'] != null ? Color(json['color']) : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Add helper getter for category (consistent with HabitModel)
  CategoryModel get category {
    try {
      return findCategoryById(categoryId) ??
          appCategories.firstWhere((c) => c.id == 'other');
    } catch (e) {
      // Fallback to ensure we always return a valid category
      return findCategoryById('other')!;
    }
  }

  // Add a fallback icon getter in case category fails (like in HabitModel)
  IconData get iconData {
    try {
      return category.icon;
    } catch (e) {
      return Icons.assignment; // Task-specific fallback icon
    }
  }
}
