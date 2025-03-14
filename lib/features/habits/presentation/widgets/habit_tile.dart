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
            Text(habit.name),
            const SizedBox(width: 8),
            _buildPriorityIndicator(context),
          ],
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
            if (habit.selectedDays.length > 0 && habit.selectedDays.length < 7)
              _buildActivedays(context),
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

                AppSnackbar.show(
                  context: context,
                  message: message,
                  backgroundColor:
                      isCompletedForDate ? Colors.red : Colors.green,
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

  Widget _buildActivedays(BuildContext context) {
    if (habit.selectedDays.isEmpty ||
        (habit.frequency == Frequency.daily &&
            habit.selectedDays.length == 7)) {
      return const SizedBox.shrink();
    }

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          ...List.generate(7, (index) {
            final isSelected = habit.selectedDays.contains(index);
            return Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: Center(
                child: Text(
                  dayLabels[index],
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
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
