import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/data/habit_service.dart';

// Repository provider
final habitsRepositoryProvider = Provider<HabitRepository>((ref) {
  final authState = ref.watch(authStateChangesProvider).asData?.value;
  return HabitRepository(userId: authState?.uid);
});

// Stream provider for reactive UI updates
final habitsStreamProvider = StreamProvider<List<HabitModel>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return repository.watchHabits();
});

// State notifier provider for operations
final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<HabitModel>>>((ref) {
  final repository = ref.watch(habitsRepositoryProvider);
  return HabitsNotifier(repository, ref);
});

// Notifier for managing habits
class HabitsNotifier extends StateNotifier<AsyncValue<List<HabitModel>>> {
  final HabitRepository _repository;
  final Ref _ref;
  HabitsNotifier(
    this._repository,
    this._ref,
  ) : super(const AsyncValue.loading()) {
    _init();
  }

  // Initialize the notifier
  Future<void> _init() async {
    _ref.listen(
      habitsStreamProvider,
      (previous, next) {
        next.whenData(
          (value) {
            state = AsyncValue.data(value);
          },
        );
      },
    );
  }

  // Add a new habit
  Future<void> createHabit(HabitModel habit) async {
    try {
      await _repository.createHabit(habit);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Update an existing habit
  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _repository.updateHabit(habit);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _repository.deleteHabit(habitId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Toggle habit completion
  Future<HabitModel> toggleHabitCompletion(
      String habitId, DateTime date) async {
    try {
      await _repository.toggleHabitCompletion(habitId, date);
      return await _repository.getHabitById(habitId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      throw e;
    }
  }

  // Get a habit by ID
  Future<HabitModel> getHabitById(String habitId) async {
    try {
      return await _repository.getHabitById(habitId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

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
