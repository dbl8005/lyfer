import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/data/repositories/habit_repository.dart';

/// A calendar view showing habit completion dates with long-press to toggle completion
class HabitCalendarView extends ConsumerStatefulWidget {
  /// Creates a calendar view for a habit
  ///
  /// The [habit] parameter is required to display completion data
  const HabitCalendarView({
    super.key,
    required this.habit,
  });

  /// The habit to display completion data for
  final HabitModel habit;

  @override
  ConsumerState<HabitCalendarView> createState() => _HabitCalendarViewState();
}

class _HabitCalendarViewState extends ConsumerState<HabitCalendarView> {
  /// The current habit model with completion data
  late HabitModel _currentHabit;

  @override
  void initState() {
    super.initState();
    _currentHabit = widget.habit;
  }

  @override
  void didUpdateWidget(HabitCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habit != widget.habit) {
      _currentHabit = widget.habit;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use current date as the fixed focused day
    final now = DateTime.now();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarHeader(context),
            TableCalendar(
              // Fix to show only one month - the current month
              firstDay: DateTime(now.year - 1, now.month, 1),
              lastDay: DateTime(now.year, now.month, now.day),
              focusedDay: now,

              // Disable day selection on tap and disable page changing
              enabledDayPredicate: (_) => true,
              onDaySelected: null, // No action on tap
              onPageChanged: null, // Disable page changing

              // Restrict available formats to month view only (removes 2-week button)
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              // Fix format to month view
              calendarFormat: CalendarFormat.month,
              // Disable format changes
              onFormatChanged: null,

              calendarStyle: const CalendarStyle(
                markersMaxCount: 1,
                // Disable default day selection indicator
                selectedDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                outsideBuilder: (context, day, focusedDay) =>
                    _buildCalendarDay(context, day, true),
                todayBuilder: (context, day, focusedDay) {
                  // Highlight today with a different color
                  return _buildCalendarDay(context, day, false);
                },
                defaultBuilder: (context, day, focusedDay) =>
                    _buildCalendarDay(context, day, false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the calendar header with title
  Widget _buildCalendarHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Completion Calendar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          Tooltip(
            message: 'Long press on a day to mark as completed',
            child: const Icon(Icons.info_outline, size: 18),
          ),
        ],
      ),
    );
  }

  /// Toggle the completion status of a habit for a specific day
  /// and update the local state to reflect the change immediately
  Future<void> _toggleHabitCompletion(DateTime day) async {
    // Only proceed if habit has an ID and the day is applicable
    if (_currentHabit.id != null) {
      final habitId = _currentHabit.id!;

      try {
        // Toggle completion status through the service
        final updatedHabit =
            await ref.read(habitsProvider.notifier).toggleHabitCompletion(
                  habitId,
                  day,
                );

        // Show feedback to user
        final dayDateFormat = DateFormat('dd/MM/yyyy').format(day);
        final isNowCompleted =
            updatedHabit.completedDates.any((date) => isSameDay(date, day));

        isNowCompleted
            ? AppSnackbar.showSuccess(
                context: context,
                message: 'Marked as completed for $dayDateFormat',
              )
            : AppSnackbar.showError(
                context: context,
                message: 'Marked as not completed for $dayDateFormat',
              );

        // Update local state to reflect changes
        setState(() {
          _currentHabit = updatedHabit;
        });
      } catch (e) {
        // Handle errors
        AppSnackbar.show(
          context: context,
          message: 'Failed to update habit: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  /// Builds a single calendar day cell with completion status
  /// Long press on a day will toggle its completion status
  Widget _buildCalendarDay(BuildContext context, DateTime day, isOutside) {
    // Check if the habit was completed on this day
    final isCompleted =
        _currentHabit.completedDates.any((date) => isSameDay(date, day));

    // Check if this is today
    final isToday = isSameDay(day, DateTime.now());

    return GestureDetector(
      // Toggle completion only on long press
      onLongPress: () => _toggleHabitCompletion(day),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Apply appropriate background colors
          color: isCompleted
              ? Colors.green.shade100
              : isToday
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Colors.transparent,
          border: Border.all(
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            day.day.toString(),
            style: TextStyle(
              color: isOutside
                  ? Colors.grey
                  : isCompleted
                      ? Colors.green.shade800
                      : isToday
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black,
              fontWeight: isCompleted || isToday ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }
}
