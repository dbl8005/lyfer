import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:lyfer/core/config/constants/ui_constants.dart';
import 'package:lyfer/core/shared/widgets/error_display.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/empty_states/empty_habits_view.dart';
import 'package:lyfer/features/habits/presentation/widgets/skeleton/habit_skeleton_item.dart';

/// A widget that handles different states (loading, error, empty, data) for habits data
class HabitStateHandler extends StatelessWidget {
  final Stream<List<HabitModel>> habitsStream;
  final VoidCallback onCreateHabit;
  final Widget Function(List<HabitModel> habits) dataBuilder;
  final VoidCallback onRetry;

  const HabitStateHandler({
    super.key,
    required this.habitsStream,
    required this.onCreateHabit,
    required this.dataBuilder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    var logger = Logger();
    return StreamBuilder<List<HabitModel>>(
      stream: habitsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return const HabitSkeletonItem();
            },
          );
        } else if (snapshot.hasError) {
          logger.e('Error fetching habits: ${snapshot.error}');
          return ErrorDisplay(
            errorMessage: '${UIConstants.errorPrefix}${snapshot.error}',
            onRetry: onRetry,
          );
        } else if (snapshot.hasData) {
          final habits = snapshot.data!;
          if (habits.isEmpty) {
            return EmptyHabitsView(onCreateHabit: onCreateHabit);
          }
          return dataBuilder(habits);
        } else {
          // Handle case when there's no data but no error (initial state)
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: UIConstants.loadingHabitsLabel,
            ),
          );
        }
      },
    );
  }
}
