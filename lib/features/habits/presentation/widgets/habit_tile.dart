import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/screens/edit_habit_screen.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';
import 'package:lyfer/core/utils/helpers/streak_calculator.dart';

class HabitTile extends ConsumerWidget {
  const HabitTile({
    super.key,
    required this.habit,
  });

  final HabitModel habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitService = ref.read(habitServiceProvider);
    // Check if habit is completed for the current period
    final isCompletedForPeriod = habit.isCompletedForCurrentPeriod();

    // Check if habit is completed specifically for today
    final isCompletedToday = habit.isCompletedForDay(DateTime.now());

    // Get number of completions in this period
    final completionsThisPeriod = habit.getCompletionsInCurrentPeriod();

    // Calculate current streak based on frequency
    final currentStreak = StreakCalculator.calculateStreak(
        habit.completedDates.toList(), habit.frequency, habit.timesPerPeriod);

    return Opacity(
      opacity: isCompletedForPeriod ? 0.5 : 1,
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (habit.description.isNotEmpty)
                Text(
                  habit.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (habit.frequency != Frequency.daily)
                Row(
                  children: [
                    Text(
                      '${completionsThisPeriod}/${habit.timesPerPeriod} this ${habit.periodLabel}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: completionsThisPeriod / habit.timesPerPeriod,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompletedForPeriod
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Streak count container
              StreakCounter(currentStreak: currentStreak),
              const SizedBox(width: 8),
              // pop up menu for more options

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      context.push('${AppRouterConsts.habitEdit}/${habit.id}',
                          extra: habit);
                    case 'delete':
                      ConfirmDialog.show(
                        context: context,
                        title: 'Delete Habit',
                        content: 'Are you sure you want to delete this habit?',
                        onConfirm: () {
                          habitService.deleteHabit(habit.id!);
                          Navigator.of(context).pop();
                        },
                      );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(LineIcons.pen),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LineIcons.trash),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
              // Completion button
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
                  String message;
                  if (habit.frequency == Frequency.daily) {
                    message = isCompletedToday
                        ? 'Habit marked as incomplete'
                        : 'Habit completed for today!';
                  } else {
                    final remainingCompletions =
                        habit.timesPerPeriod - completionsThisPeriod;
                    message = isCompletedToday
                        ? 'Removed completion for today'
                        : remainingCompletions <= 0
                            ? 'Goal reached for this ${habit.periodLabel}!'
                            : '${remainingCompletions - 1} more to go this ${habit.periodLabel}';
                  }

                  AppSnackbar.show(
                    context: context,
                    message: message,
                    backgroundColor:
                        isCompletedToday ? Colors.red : Colors.green,
                  );
                },
              ),
            ],
          ),
          onTap: () {
            // Navigate to habit details
            context.push(
              '${AppRouterConsts.habitDetails}/${habit.id}',
              extra: habit,
            );
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
        child: Tooltip(
          message: 'Streak',
          child: Row(
            children: [
              Text(
                '$currentStreak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 4),
              Icon(LineIcons.link,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ],
          ),
        ));
  }
}
