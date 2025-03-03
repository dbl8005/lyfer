import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';

class HabitModel {
  final String? id; // Nullable since Firestore will assign it
  final String name;
  final IconData icon;
  final DateTime createdAt;
  final Color? color;
  final DaySection preferredTime;
  final String description;
  final int streakCount;
  final int targetDays;
  final Frequency frequency;
  final List<DateTime> completedDates;
  final bool isArchived;
  final Reminder reminderType;
  final DaySection? reminderTime;
  final List<String>? tags;
  final int? priority;
  final Map<DateTime, String>? notes;

  HabitModel({
    this.id, // Optional since Firestore will assign it
    required this.name,
    required this.icon,
    DateTime? createdAt,
    this.color,
    required this.preferredTime,
    this.description = '',
    this.streakCount = 0,
    this.targetDays = 21,
    this.frequency = Frequency.daily,
    List<DateTime>? completedDates,
    this.isArchived = false,
    this.reminderType = Reminder.none,
    this.reminderTime,
    this.tags,
    this.priority,
    this.notes,
  })  : createdAt = createdAt ?? DateTime.now(),
        completedDates = completedDates ?? [];

  // Copy with method for immutability
  HabitModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    DaySection? preferredTime,
    String? description,
    int? streakCount,
    int? targetDays,
    Frequency? frequency,
    List<DateTime>? completedDates,
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
      icon: icon ?? this.icon,
      createdAt: createdAt,
      color: color ?? this.color,
      preferredTime: preferredTime ?? this.preferredTime,
      description: description ?? this.description,
      streakCount: streakCount ?? this.streakCount,
      targetDays: targetDays ?? this.targetDays,
      frequency: frequency ?? this.frequency,
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
      'icon': icon.codePoint,
      'createdAt': Timestamp.fromDate(createdAt),
      'color': color?.value ?? null,
      'preferredTime': preferredTime.index,
      'description': description,
      'streakCount': streakCount,
      'targetDays': targetDays,
      'frequency': frequency.index,
      'completedDates':
          completedDates.map((date) => Timestamp.fromDate(date)).toList(),
      'isArchived': isArchived,
      'reminderType': reminderType.index,
      'reminderTime': reminderTime?.index,
      'tags': tags,
      'priority': priority,
      'notes': notes?.map(
        (key, value) => MapEntry(Timestamp.fromDate(key).toString(), value),
      ),
    };
  }

  // From JSON for Firestore
  factory HabitModel.fromJson(String id, Map<String, dynamic> json) {
    return HabitModel(
      id: id, // Firestore document ID
      name: json['name'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      color: json['color'] != null ? Color(json['color'] as int) : null,
      preferredTime: DaySection.values[json['preferredTime'] as int],
      description: json['description'] as String,
      streakCount: json['streakCount'] as int,
      targetDays: json['targetDays'] as int,
      frequency: Frequency.values[json['frequency'] as int],
      completedDates: (json['completedDates'] as List)
          .map((date) => (date as Timestamp).toDate())
          .toList(),
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
}
