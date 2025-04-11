import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/utils/helpers/streak_calculator.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/data/repositories/habit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habits_provider.g.dart';

/// Custom exceptions for habit operations
class HabitsException implements Exception {
  final String message;
  HabitsException(this.message);

  @override
  String toString() => message;
}

class UnauthenticatedUserException extends HabitsException {
  UnauthenticatedUserException() : super('User not authenticated');
}

@riverpod
class HabitsRepository extends _$HabitsRepository {
  /// Gets repository instance for an authenticated user
  HabitRepository _getRepository() {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    if (authState == null) {
      throw UnauthenticatedUserException();
    }
    return HabitRepository(userId: authState.uid);
  }

  @override
  Future<List<HabitModel>> build() async {
    try {
      return await _getRepository().getHabits();
    } on UnauthenticatedUserException {
      return []; // Return empty list if not authenticated
    } catch (e) {
      throw HabitsException('Failed to load habits: $e');
    }
  }

  /// Stream provider for reactive UI updates
  Stream<List<HabitModel>> habitsStream() {
    try {
      return _getRepository().watchHabits().handleError(
            (error) => throw HabitsException('Error watching habits: $error'),
          );
    } on UnauthenticatedUserException {
      return Stream.value([]);
    } catch (e) {
      return Stream.error(HabitsException('Failed to stream habits: $e'));
    }
  }

  /// Add a new habit
  Future<void> createHabit(HabitModel habit) async {
    try {
      await _getRepository().createHabit(habit);
      ref.invalidateSelf();
    } catch (e) {
      throw HabitsException('Failed to create habit: $e');
    }
  }

  /// Update an existing habit
  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _getRepository().updateHabit(habit);
      ref.invalidateSelf();
    } catch (e) {
      throw HabitsException('Failed to update habit: $e');
    }
  }

  /// Delete a habit by ID
  Future<void> deleteHabit(String habitId) async {
    try {
      await _getRepository().deleteHabit(habitId);
      ref.invalidateSelf();
    } catch (e) {
      throw HabitsException('Failed to delete habit: $e');
    }
  }

  /// Toggle habit completion for a specific date
  Future<HabitModel> toggleHabitCompletion(
      String habitId, DateTime date) async {
    try {
      final repository = _getRepository();
      await repository.toggleHabitCompletion(habitId, date);
      return await repository.getHabitById(habitId);
    } catch (e) {
      throw HabitsException('Failed to toggle habit completion: $e');
    }
  }

  /// Get a habit by ID
  Future<HabitModel> getHabitById(String habitId) async {
    try {
      return await _getRepository().getHabitById(habitId);
    } catch (e) {
      throw HabitsException('Failed to get habit: $e');
    }
  }

  /// Update a habit's streak
  Future<int> updateStreak(String habitId, int newStreak) async {
    try {
      return await _getRepository().updateHabitStreak(habitId, newStreak);
    } catch (e) {
      throw HabitsException('Failed to update streak: $e');
    }
  }

  /// Calculate and update the streak for a habit
  int calculateAndUpdateStreak(HabitModel habit) {
    if (habit.id == null) {
      throw HabitsException('Habit ID cannot be null');
    }

    final newStreak = StreakCalculator.calculateStreak(
      habit.completedDates.toList(),
      habit.frequency,
      habit.timesPerPeriod,
    );

    updateStreak(habit.id!, newStreak);
    return newStreak;
  }
}

@riverpod
Stream<List<HabitModel>> habitsStream(HabitsStreamRef ref) {
  return ref.watch(habitsRepositoryProvider.notifier).habitsStream();
}

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void update(DateTime date) => state = date;
}

@riverpod
class CurrentSection extends _$CurrentSection {
  @override
  DaySection build() {
    return _getDaySectionFromTime(TimeOfDay.now());
  }

  DaySection _getDaySectionFromTime(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return DaySection.morning;
    if (hour >= 12 && hour < 17) return DaySection.afternoon;
    if (hour >= 17 && hour < 21) return DaySection.evening;
    return DaySection.night;
  }
}

@riverpod
class GroupedHabits extends _$GroupedHabits {
  @override
  Map<DaySection, List<HabitModel>> build() {
    return ref.watch(habitsStreamProvider).when(
          data: _groupHabitsBySection,
          loading: _getEmptyGroupedHabits,
          error: (_, __) => _getEmptyGroupedHabits(),
        );
  }

  Map<DaySection, List<HabitModel>> _groupHabitsBySection(
      List<HabitModel> habits) {
    final result = _getEmptyGroupedHabits();
    for (final habit in habits) {
      result[habit.daySection]?.add(habit);
    }
    return result;
  }

  Map<DaySection, List<HabitModel>> _getEmptyGroupedHabits() => {
        for (final section in DaySection.values) section: <HabitModel>[],
      };
}
