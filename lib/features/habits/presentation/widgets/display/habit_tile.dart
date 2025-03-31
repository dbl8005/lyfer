import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/core/widgets/custom_card.dart';
import 'package:lyfer/core/widgets/circular_icon.dart';
import 'package:lyfer/core/widgets/progress_indicator_with_label.dart';
import 'package:lyfer/core/widgets/responsive_padding.dart';
import 'package:lyfer/core/widgets/status_indicator.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';
import 'package:lyfer/features/habits/presentation/screens/edit_habit_screen.dart';
import 'package:lyfer/features/habits/presentation/widgets/display/active_days_indicator.dart';
import 'package:lyfer/features/habits/presentation/widgets/display/streak_counter.dart';
import 'package:lyfer/features/habits/data/repositories/habit_repository.dart';
import 'package:lyfer/core/utils/helpers/streak_calculator.dart';

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
    final habitService = ref.read(habitsProvider.notifier);
    final theme = Theme.of(context);

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

    return CustomCard(
      margin: EdgeInsets.zero, // Remove default card margin

      child: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 300;

        return ResponsivePadding(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircularIcon(
              icon: habit.category.icon,
              color: habit.color ?? habit.category.defaultColor,
              size: isNarrow ? 36 : 44,
              iconSize: isNarrow ? 20 : 24,
            ),
            title: Row(
              children: [
                StatusIndicator(
                  icon: habit.priority.icon,
                  color: habit.priority.getColor(context),
                  tooltip: 'Priority: ${habit.priority.name}',
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    habit.name,
                    style: theme.textTheme.titleMedium,
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
                    habit.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (habit.frequency != Frequency.daily)
                  ProgressIndicatorWithLabel(
                    label:
                        '${completionsThisPeriod}/${habit.timesPerPeriod} this ${habit.periodLabel}',
                    progress: completionsThisPeriod / habit.timesPerPeriod,
                    progressColor: isCompletedForPeriod
                        ? Colors.green
                        : theme.colorScheme.primary,
                  ),
                if (habit.selectedDays.isNotEmpty &&
                    habit.selectedDays.length < 7)
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
                StreakCounter(currentStreak: currentStreak),

                // More options menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: isNarrow ? 20 : 24),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        context.push('${AppRouterConsts.habitEdit}/${habit.id}',
                            extra: habit);
                      case 'delete':
                        ConfirmDialog.show(
                          context: context,
                          title: 'Delete Habit',
                          content:
                              'Are you sure you want to delete this habit?',
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
                    isCompletedForDate
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: isCompletedForDate ? Colors.green : Colors.grey,
                    size: isNarrow ? 20 : 24,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Call the service to toggle habit completion
                    habitService.toggleHabitCompletion(habit.id!, selectedDate);
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
      }),
    );
  }
}
