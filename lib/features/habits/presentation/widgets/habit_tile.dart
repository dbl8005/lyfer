import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';
import 'package:lyfer/features/habits/utils/streak_calculator.dart';

class HabitTile extends ConsumerWidget {
  const HabitTile({
    super.key,
    required this.habit,
  });

  final HabitModel habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompletedToday = habit.completedDates.any(
      (date) =>
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day,
    );

    // Calculate current streak
    final currentStreak =
        StreakCalculator.calculateStreak(habit.completedDates.toList());

    return Opacity(
      opacity: isCompletedToday ? 0.5 : 1,
      child: Card(
        color: isCompletedToday
            ? Theme.of(context).colorScheme.primaryContainer.withAlpha(50)
            : Theme.of(context).colorScheme.surface,
        margin: EdgeInsets.zero, // Remove default card margin
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (habit.color ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: LineIcon(
              HabitIcon.values.firstWhere((e) => e.name == habit.icon).icon,
              color: habit.color ?? Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          title: Text(
            habit.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: habit.description.isNotEmpty
              ? Text(
                  habit.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Streak count container
              StreakCounter(currentStreak: currentStreak),
              const SizedBox(width: 8),
              // Completion button
              // TODO Change functionality to hold 2 seconds to mark as completed
              // TODO Add a confirmation dialog before marking as uncompleted
              IconButton(
                icon: Icon(
                  isCompletedToday ? Icons.check_circle : Icons.circle_outlined,
                  color: isCompletedToday ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  // Call the service to toggle habit completion
                  final habitService = ref.read(habitServiceProvider);
                  habitService.toggleHabitCompletion(habit.id!, DateTime.now());

                  // Show feedback with snackbar
                  AppSnackbar.show(
                    context: context,
                    message: isCompletedToday
                        ? 'Habit marked as incomplete'
                        : 'Habit completed for today!',
                    backgroundColor:
                        isCompletedToday ? Colors.red : Colors.green,
                  );
                },
              ),
            ],
          ),
          onTap: () {
            // Handle habit tap - perhaps show details or mark as completed
          },
        ),
      ),
    );
  }
}

class StreakCounter extends StatelessWidget {
  const StreakCounter({
    super.key,
    required this.currentStreak,
  });

  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final streakColor = switch (currentStreak) {
      0 => Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      < 5 => Colors.red.shade300,
      < 10 => Colors.red.shade400,
      < 20 => Colors.red.shade500,
      < 30 => Colors.red.shade600,
      < 50 => Colors.red.shade700,
      < 100 => Colors.red.shade800,
      >= 100 => Colors.red.shade900,
      _ => Colors.grey
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: streakColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${currentStreak} ${currentStreak == 1 ? 'day' : 'days'}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
