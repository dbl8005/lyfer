import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:lyfer/features/tasks/domain/enums/task_enums.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool isCompleted;
  final TaskCategory category;
  final TaskPriority priority;
  final Color? color;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.none,
    this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskCategory? category,
    TaskPriority? priority,
    Color? color,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id is managed by Firestore
      'title': title,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'category': category.toString(),
      'priority': priority.toString(),
      'color': color?.value,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json, {String? id}) {
    return Task(
      id: id, // Use the provided id (from Firestore document ID)
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      category: TaskCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
          orElse: () => TaskCategory.other),
      priority: TaskPriority.values.firstWhere(
          (e) => e.toString() == json['priority'],
          orElse: () => TaskPriority.none),
      color: json['color'] != null ? Color(json['color']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Create from Firestore document snapshot
  factory Task.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Task.fromJson(data, id: documentId);
  }
}
