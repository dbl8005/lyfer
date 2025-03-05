import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';

class HabitModel {
  final String? id;
  final String name;
  final String icon;
  final DateTime createdAt;
  final Color? color;
  final DaySection preferredTime;
  final String description;
  final int streakCount;
  final int? targetDays;
  final Frequency frequency;
  final int timesPerPeriod; // New field - e.g., 3 times per week
  final Set<DateTime> completedDates;
  final bool isArchived;
  final Reminder reminderType;
  final DaySection? reminderTime;
  final List<String>? tags;
  final int? priority;
  final Map<DateTime, String>? notes;

  HabitModel({
    this.id,
    required this.name,
    required this.icon, // Store as string instead of IconData
    DateTime? createdAt,
    this.color,
    required this.preferredTime,
    this.description = '',
    this.streakCount = 0,
    this.targetDays,
    this.frequency = Frequency.daily,
    this.timesPerPeriod = 1, // Default is 1 time per period
    Set<DateTime>? completedDates,
    this.isArchived = false,
    this.reminderType = Reminder.none,
    this.reminderTime,
    this.tags,
    this.priority,
    this.notes,
  })  : createdAt = createdAt ?? DateTime.now(),
        completedDates = completedDates ?? {};

  // Copy with method
  HabitModel copyWith({
    String? id,
    String? name,
    String? iconName,
    Color? color,
    DaySection? preferredTime,
    String? description,
    int? streakCount,
    // Use Object? to distinguish between null (set to null) and not provided (keep existing)
    Object? targetDays = const Object(),
    Frequency? frequency,
    int? timesPerPeriod,
    Set<DateTime>? completedDates,
    bool? isArchived,
    Reminder? reminderType,
    DaySection? reminderTime,
    List<String>? tags,
    int? priority,
    Map<DateTime, String>? notes,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: iconName ?? this.icon,
      createdAt: createdAt,
      color: color ?? this.color,
      preferredTime: preferredTime ?? this.preferredTime,
      description: description ?? this.description,
      streakCount: streakCount ?? this.streakCount,
      // Check if targetDays was explicitly provided (even if null)
      targetDays:
          targetDays != const Object() ? targetDays as int? : this.targetDays,
      frequency: frequency ?? this.frequency,
      timesPerPeriod: timesPerPeriod ?? this.timesPerPeriod,
      completedDates: completedDates ?? this.completedDates,
      isArchived: isArchived ?? this.isArchived,
      reminderType: reminderType ?? this.reminderType,
      reminderTime: reminderTime ?? this.reminderTime,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
    );
  }

  // To JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconName': icon, // Store as string
      'createdAt': Timestamp.fromDate(createdAt),
      'color': color?.value,
      'preferredTime': preferredTime.index,
      'description': description,
      'streakCount': streakCount,
      'targetDays': targetDays,
      'frequency': frequency.index,
      'timesPerPeriod': timesPerPeriod,
      'completedDates':
          completedDates.map((date) => Timestamp.fromDate(date)).toList(),
      'isArchived': isArchived,
      'reminderType': reminderType.index,
      'reminderTime': reminderTime?.index,
      'tags': tags,
      'priority': priority,
      'notes': notes?.map(
        (key, value) => MapEntry(
          Timestamp.fromDate(key).toString(),
          value,
        ),
      ),
    };
  }

  // From JSON for Firestore
  factory HabitModel.fromJson(String id, Map<String, dynamic> json) {
    return HabitModel(
      id: id,
      name: json['name'] as String,
      icon: json['iconName'], // Read as string
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      color: json['color'] != null ? Color(json['color'] as int) : null,
      preferredTime: DaySection.values[json['preferredTime'] as int],
      description: json['description'] as String,
      streakCount: json['streakCount'] as int,
      targetDays: json['targetDays'] as int?,
      frequency: Frequency.values[json['frequency'] as int],
      timesPerPeriod: json['timesPerPeriod'] as int? ?? 1,
      completedDates: (json['completedDates'] as List)
          .map((date) => (date as Timestamp).toDate())
          .toSet(),
      isArchived: json['isArchived'] as bool,
      reminderType: Reminder.values[json['reminderType'] as int],
      reminderTime: json['reminderTime'] != null
          ? DaySection.values[json['reminderTime'] as int]
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      priority: json['priority'] as int?,
      notes: json['notes'] != null
          ? (json['notes'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                Timestamp.fromDate(DateTime.parse(key)).toDate(),
                value as String,
              ),
            )
          : null,
    );
  }

  // Get appropriate period label based on frequency
  String get periodLabel {
    return switch (frequency) {
      Frequency.daily => 'day',
      Frequency.weekly => 'week',
      Frequency.monthly => 'month',
    };
  }

  // Helper to check if habit is completed for current period
  bool isCompletedForCurrentPeriod() {
    final now = DateTime.now();

    switch (frequency) {
      case Frequency.daily:
        // For daily habits, check if completed today
        return completedDates.any((date) =>
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day);

      case Frequency.weekly:
        // For weekly habits, calculate start of week (assuming weeks start on Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startDate =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

        // Count completions this week
        int completionsThisWeek = 0;
        for (final date in completedDates) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          if (!normalizedDate.isBefore(startDate) &&
              normalizedDate.difference(startDate).inDays < 7) {
            completionsThisWeek++;
          }
        }
        return completionsThisWeek >= timesPerPeriod;

      case Frequency.monthly:
        // For monthly habits, get completions in current month
        int completionsThisMonth = 0;
        for (final date in completedDates) {
          if (date.year == now.year && date.month == now.month) {
            completionsThisMonth++;
          }
        }
        return completionsThisMonth >= timesPerPeriod;
    }
  }

  // Get completions in current period
  int getCompletionsInCurrentPeriod() {
    final now = DateTime.now();

    switch (frequency) {
      case Frequency.daily:
        return completedDates.any((date) =>
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day)
            ? 1
            : 0;

      case Frequency.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startDate =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

        int completionsThisWeek = 0;
        for (final date in completedDates) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          if (!normalizedDate.isBefore(startDate) &&
              normalizedDate.difference(startDate).inDays < 7) {
            completionsThisWeek++;
          }
        }
        return completionsThisWeek;

      case Frequency.monthly:
        return completedDates
            .where((date) => date.year == now.year && date.month == now.month)
            .length;
    }
  }

  // Check if habit is completed for a specific day
  bool isCompletedForDay(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    return completedDates.any((completionDate) {
      final normalizedDate = DateTime(
        completionDate.year,
        completionDate.month,
        completionDate.day,
      );
      return normalizedDate.isAtSameMomentAs(targetDate);
    });
  }
}
