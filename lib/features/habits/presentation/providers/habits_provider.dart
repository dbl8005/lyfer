import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/utils/helpers/streak_calculator.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/data/repositories/habit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habits_provider.g.dart';

//Repository provider
@riverpod
class HabitsRepository extends _$HabitsRepository {
  @override
  HabitRepository build() {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    return HabitRepository(userId: authState?.uid);
  }

  // Stream provider for reactive UI updates
  Stream<List<HabitModel>> habitsStream() {
    final repository = HabitRepository(userId: state.userId);
    return repository.watchHabits();
  }

  // Add a new habit
  Future<void> createHabit(HabitModel habit) async {
    final repository = HabitRepository(userId: state.userId);
    await repository.createHabit(habit);
  }

  // Update an existing habit
  Future<void> updateHabit(HabitModel habit) async {
    final repository = HabitRepository(userId: state.userId);
    await repository.updateHabit(habit);
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    final repository = HabitRepository(userId: state.userId);
    await repository.deleteHabit(habitId);
  }

  // Toggle habit completion
  Future<HabitModel> toggleHabitCompletion(
      String habitId, DateTime date) async {
    final repository = HabitRepository(userId: state.userId);
    await repository.toggleHabitCompletion(habitId, date);
    return await repository.getHabitById(habitId);
  }

  // Get a habit by ID
  Future<HabitModel> getHabitById(String habitId) async {
    final repository = HabitRepository(userId: state.userId);
    return await repository.getHabitById(habitId);
  }

  // Update a habit's streak
  Future<int> updateStreak(String habitId, int newStreak) async {
    final repository = HabitRepository(userId: state.userId);
    return await repository.updateHabitStreak(habitId, newStreak);
  }

// Get streak for a habit
  int getStreakForHabit(HabitModel habit) {
    final newStreak = StreakCalculator.calculateStreak(
      habit.completedDates.toList(),
      habit.frequency,
      habit.timesPerPeriod,
    );
    updateStreak(habit.id!, newStreak);
    return newStreak;
  }
}

// Stream provider for habitsStream
@riverpod
Stream<List<HabitModel>> habitsStream(HabitsStreamRef ref) {
  return ref.watch(habitsRepositoryProvider.notifier).habitsStream();
}

// Date Selection provider
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void update(DateTime date) {
    state = date;
  }
}

@riverpod
class CurrentSection extends _$CurrentSection {
  @override
  DaySection build() {
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
  }
}

// Grouped habits provider
@riverpod
class GroupedHabits extends _$GroupedHabits {
  @override
  Map<DaySection, List<HabitModel>> build() {
    // Watch the habitsStreamProvider, which returns an AsyncValue
    final habitsAsyncValue = ref.watch(habitsStreamProvider);

    // Use `when` to handle the different states
    return habitsAsyncValue.when(
      data: (habits) => _groupHabitsBySection(habits),
      loading: () => _getEmptyGroupedHabits(),
      error: (_, __) => _getEmptyGroupedHabits(),
    );
  }

  // Helper function to group habits by section
  Map<DaySection, List<HabitModel>> _groupHabitsBySection(
      List<HabitModel> habits) {
    return {
      DaySection.morning: habits
          .where((habit) => habit.daySection == DaySection.morning)
          .toList(),
      DaySection.afternoon: habits
          .where((habit) => habit.daySection == DaySection.afternoon)
          .toList(),
      DaySection.evening: habits
          .where((habit) => habit.daySection == DaySection.evening)
          .toList(),
      DaySection.night: habits
          .where((habit) => habit.daySection == DaySection.night)
          .toList(),
      DaySection.allDay: habits
          .where((habit) => habit.daySection == DaySection.allDay)
          .toList(),
    };
  }

  // Helper function to return an empty grouped habits map
  Map<DaySection, List<HabitModel>> _getEmptyGroupedHabits() {
    return {
      DaySection.morning: [],
      DaySection.afternoon: [],
      DaySection.evening: [],
      DaySection.night: [],
      DaySection.allDay: [],
    };
  }
}
