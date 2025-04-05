// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:lyfer/core/shared/models/category_model.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/notes/models/note_model.dart';

class HabitModel {
  final String? id;
  final String name;
  final String categoryId; // Replaces icon
  final DateTime createdAt;
  final Color? color;
  final DaySection daySection;
  final String description;
  final int streakCount;
  final int? targetDays;
  final Frequency frequency;
  final int timesPerPeriod; // New field - e.g., 3 times per week
  final Set<DateTime> completedDates;
  final bool isArchived;
  final Reminder reminderType;
  final TimeOfDay? reminderTime; // New: specific time for reminder
  final List<String>? tags;
  final Priority priority; // Updated to use Priority enum
  final List<NoteModel> notes;
  final Set<WeekDay> selectedDays; // New: days of week (0 = Monday, 6 = Sunday)
  final bool isPinned;
  final int bestStreak;
  HabitModel({
    this.id,
    required this.name,
    this.categoryId = 'other',
    required this.createdAt,
    this.color,
    this.daySection = DaySection.allDay,
    this.description = '',
    this.streakCount = 0,
    this.targetDays,
    required this.frequency,
    this.timesPerPeriod = 1,
    required this.completedDates,
    this.isArchived = false,
    this.reminderType = Reminder.none,
    this.reminderTime,
    this.tags,
    this.priority = Priority.none,
    this.notes = const [],
    required this.selectedDays,
    this.isPinned = false,
    this.bestStreak = 0,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    DateTime? createdAt,
    Color? color,
    DaySection? daySection,
    String? description,
    int? streakCount,
    int? targetDays,
    Frequency? frequency,
    int? timesPerPeriod,
    Set<DateTime>? completedDates,
    bool? isArchived,
    Reminder? reminderType,
    TimeOfDay? reminderTime,
    List<String>? tags,
    Priority? priority,
    List<NoteModel>? notes,
    Set<WeekDay>? selectedDays,
    bool? isPinned,
    int? bestStreak,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      daySection: daySection ?? this.daySection,
      description: description ?? this.description,
      streakCount: streakCount ?? this.streakCount,
      targetDays: targetDays ?? this.targetDays,
      frequency: frequency ?? this.frequency,
      timesPerPeriod: timesPerPeriod ?? this.timesPerPeriod,
      completedDates: completedDates ?? this.completedDates,
      isArchived: isArchived ?? this.isArchived,
      reminderType: reminderType ?? this.reminderType,
      reminderTime: reminderTime ?? this.reminderTime,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      selectedDays: selectedDays ?? this.selectedDays,
      isPinned: isPinned ?? this.isPinned,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  // Get the category from the category provider
  CategoryModel get category {
    try {
      return findCategoryById(categoryId) ??
          appCategories.firstWhere((category) => category.id == 'other');
    } catch (e) {
      // Fallback to ensure we always return a valid category
      return findCategoryById('other')!;
    }
  }

  // Serialize to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'createdAt': Timestamp.fromDate(createdAt),
      'color': color?.value,
      'daySection': daySection.index,
      'description': description,
      'streakCount': streakCount,
      'targetDays': targetDays,
      'frequency': frequency.index,
      'timesPerPeriod': timesPerPeriod,
      'completedDates':
          completedDates.map((date) => Timestamp.fromDate(date)).toList(),
      'isArchived': isArchived,
      'reminderType': reminderType.index,
      'reminderTime': reminderTime != null
          ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
          : null,
      'tags': tags,
      'priority': priority.index,
      'notes': notes.map((note) => note.toJson()).toList(),
      'selectedDays': selectedDays.map((day) => day.index).toList(),
      'isPinned': isPinned,
      'bestStreak': bestStreak,
    };
  }

  // Create from Firestore document
  factory HabitModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    final id = docId ?? json['id'];

    // Handle completed dates
    Set<DateTime> completedDates = {};
    if (json['completedDates'] != null) {
      completedDates = (json['completedDates'] as List)
          .map((timestamp) => (timestamp as Timestamp).toDate())
          .toSet();
    }

    // Handle selected days
    Set<WeekDay> selectedDays = {};
    if (json['selectedDays'] != null) {
      selectedDays = (json['selectedDays'] as List)
          .map((dayIndex) => WeekDay.values[dayIndex as int])
          .toSet();
    }

    // Handle notes
    List<NoteModel> notes = [];
    if (json['notes'] != null) {
      notes = (json['notes'] as List)
          .map((noteJson) => NoteModel.fromJson(noteJson))
          .toList();
    }

    // Handle reminder time
    TimeOfDay? reminderTime;
    if (json['reminderTime'] != null) {
      final timeMap = json['reminderTime'] as Map<String, dynamic>;
      reminderTime = TimeOfDay(
        hour: timeMap['hour'] as int,
        minute: timeMap['minute'] as int,
      );
    }

    return HabitModel(
      id: id,
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? 'other',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      color: json['color'] != null ? Color(json['color'] as int) : null,
      daySection: json['daySection'] != null
          ? DaySection.values[json['daySection'] as int]
          : DaySection.allDay,
      description: json['description'] ?? '',
      streakCount: json['streakCount'] ?? 0,
      targetDays: json['targetDays'],
      frequency: json['frequency'] != null
          ? Frequency.values[json['frequency'] as int]
          : Frequency.daily,
      timesPerPeriod: json['timesPerPeriod'] ?? 1,
      completedDates: completedDates,
      isArchived: json['isArchived'] ?? false,
      reminderType: json['reminderType'] != null
          ? Reminder.values[json['reminderType'] as int]
          : Reminder.none,
      reminderTime: reminderTime,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      priority: json['priority'] != null
          ? Priority.values[json['priority'] as int]
          : Priority.none,
      notes: notes,
      selectedDays: selectedDays,
      isPinned: json['isPinned'] ?? false,
      bestStreak: json['bestStreak'] ?? 0,
    );
  }

  // Helper methods for habit functionality
  bool isCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  bool isScheduledForToday() {
    final now = DateTime.now();
    final weekDay = WeekDay
        .values[now.weekday - 1]; // Convert DateTime weekday to WeekDay enum
    return selectedDays.contains(weekDay);
  }

  int calculateCompletionRate() {
    if (completedDates.isEmpty) return 0;

    // Calculate based on frequency
    switch (frequency) {
      case Frequency.daily:
        final daysFromCreation =
            DateTime.now().difference(createdAt).inDays + 1;
        final scheduledDays = daysFromCreation * selectedDays.length / 7;
        return ((completedDates.length / scheduledDays) * 100).round();

      case Frequency.weekly:
        final weeksFromCreation =
            DateTime.now().difference(createdAt).inDays / 7;
        return ((completedDates.length / weeksFromCreation) * 100).round();

      case Frequency.monthly:
        final monthsFromCreation = (DateTime.now().year - createdAt.year) * 12 +
            (DateTime.now().month - createdAt.month);
        return ((completedDates.length / monthsFromCreation) * 100).round();

      default:
        return 0;
    }
  }

  isCompletedForDate(DateTime selectedDate) {
    return completedDates.any((date) {
      return date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
    });
  }
}
