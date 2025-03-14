import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';

// Date selection provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Current section provider
final currentSectionProvider = Provider<DaySection>((ref) {
  final now = TimeOfDay.now();
  final hour = now.hour;

  if (hour >= 5 && hour < 12) {
    return DaySection.morning;
  } else if (hour >= 12 && hour < 17) {
    return DaySection.afternoon;
  } else if (hour >= 17 && hour < 21) {
    return DaySection.evening;
  } else {
    return DaySection.night;
  }
});

// Grouped habits provider
final groupedHabitsProvider =
    Provider<Map<DaySection, List<HabitModel>>>((ref) {
  final habitsAsyncValue = ref.watch(habitsStreamProvider);

  return habitsAsyncValue.when(
    data: (habits) => _groupHabitsBySection(habits),
    loading: () => _getEmptyGroupedHabits(),
    error: (_, __) => _getEmptyGroupedHabits(),
  );
});

// Stream of habits
final habitsStreamProvider = StreamProvider<List<HabitModel>>((ref) {
  return ref.watch(habitServiceProvider).getHabits();
});

// Helper function to group habits by section
Map<DaySection, List<HabitModel>> _groupHabitsBySection(
    List<HabitModel> habits) {
  return {
    DaySection.morning: habits
        .where((habit) => habit.preferredTime == DaySection.morning)
        .toList(),
    DaySection.afternoon: habits
        .where((habit) => habit.preferredTime == DaySection.afternoon)
        .toList(),
    DaySection.evening: habits
        .where((habit) => habit.preferredTime == DaySection.evening)
        .toList(),
    DaySection.night: habits
        .where((habit) => habit.preferredTime == DaySection.night)
        .toList(),
    DaySection.allDay: habits
        .where((habit) => habit.preferredTime == DaySection.allDay)
        .toList(),
  };
}

Map<DaySection, List<HabitModel>> _getEmptyGroupedHabits() {
  return {
    DaySection.morning: [],
    DaySection.afternoon: [],
    DaySection.evening: [],
    DaySection.night: [],
    DaySection.allDay: [],
  };
}
