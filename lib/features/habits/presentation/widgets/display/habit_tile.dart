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
import 'package:lyfer/features/habits/presentation/widgets/display/active_days_indicator.dart';
import 'package:lyfer/features/habits/presentation/widgets/display/streak_counter.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';
import 'package:lyfer/core/utils/helpers/streak_calculator.dart';
import 'package:lyfer/core/config/enums/habit_categories.dart';

class HabitTile extends ConsumerWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.selectedDate,
  });

  final HabitModel habit;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitService = ref.read(habitServiceProvider);

    // Check if habit is completed for the current period
    final isCompletedForPeriod = habit.isCompletedForCurrentPeriod();

    // Check if habit is completed specifically for the selected date
    final isCompletedForDate = habit.isCompletedForDay(selectedDate);

    // Check if selected date is today
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    // Get number of completions in this period
    final completionsThisPeriod = habit.getCompletionsInCurrentPeriod();

    // Calculate current streak based on frequency
    final currentStreak = StreakCalculator.calculateStreak(
        habit.completedDates.toList(), habit.frequency, habit.timesPerPeriod);

    return Card(
      color: isCompletedForDate
          ? Colors.grey.withOpacity(0.4)
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: habit.color ?? habit.category.defaultColor,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: LineIcon(
            habit.category.icon,
            size: 24,
            color: habit.color ?? habit.category.defaultColor,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: habit.priority.getColor(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                habit.priority.icon,
                size: 16,
                color: habit.priority.getColor(context),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                habit.name,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.description.isNotEmpty)
              Text(
                style: Theme.of(context).textTheme.bodySmall,
                habit.description,
                maxLines: 2,
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
            if (habit.selectedDays.isNotEmpty && habit.selectedDays.length < 7)
              ActiveDaysIndicator(
                selectedDays: habit.selectedDays.toList(),
                frequency: habit.frequency,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streak count container
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreakCounter(currentStreak: currentStreak),
              ],
            ),
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
                isCompletedForDate ? Icons.check_circle : Icons.circle_outlined,
                color: isCompletedForDate ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                // Call the service to toggle habit completion
                final habitService = ref.read(habitServiceProvider);
                habitService.toggleHabitCompletion(habit.id!, selectedDate);

                // Show feedback with snackbar
                String message;
                if (habit.frequency == Frequency.daily) {
                  message = isCompletedForDate
                      ? 'Habit marked as incomplete'
                      : 'Habit completed for today!';
                } else {
                  final remainingCompletions =
                      habit.timesPerPeriod - completionsThisPeriod;
                  message = isCompletedForDate
                      ? 'Removed completion for today'
                      : remainingCompletions <= 0
                          ? 'Goal reached for this ${habit.periodLabel}!'
                          : '${remainingCompletions - 1} more to go this ${habit.periodLabel}';
                }

                isCompletedForDate
                    ? AppSnackbar.showSuccess(
                        context: context,
                        message: message,
                      )
                    : AppSnackbar.showError(
                        context: context,
                        message: message,
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
    );
  }

  // Add a method to show priority indicator
  Widget _buildPriorityIndicator(BuildContext context) {
    // Only show if priority is not none
    if (habit.priority == Priority.none) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Priority: ${habit.priority.label}',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: habit.priority.getColor(context).withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          habit.priority.icon,
          size: 16,
          color: habit.priority.getColor(context),
        ),
      ),
    );
  }
}
