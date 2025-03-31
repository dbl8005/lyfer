import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/config/constants/ui_constants.dart';
import 'package:lyfer/core/widgets/error_display.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/empty_states/empty_habits_view.dart';

/// A widget that handles different states (loading, error, empty, data) for habits data
class HabitStateHandler extends StatelessWidget {
  final AsyncValue<List<HabitModel>> habitsAsyncValue;
  final VoidCallback onCreateHabit;
  final Widget Function(List<HabitModel> habits) dataBuilder;
  final VoidCallback onRetry;

  const HabitStateHandler({
    super.key,
    required this.habitsAsyncValue,
    required this.onCreateHabit,
    required this.dataBuilder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return habitsAsyncValue.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          semanticsLabel: UIConstants.loadingHabitsLabel,
        ),
      ),
      error: (error, stack) => ErrorDisplay(
        errorMessage: '${UIConstants.errorPrefix}$error',
        onRetry: onRetry,
      ),
      data: (habits) {
        if (habits.isEmpty) {
          return EmptyHabitsView(onCreateHabit: onCreateHabit);
        }
        return dataBuilder(habits);
      },
    );
  }
}
