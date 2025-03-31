import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime today;
  final VoidCallback onPreviousDayPressed;
  final VoidCallback onNextDayPressed;
  final VoidCallback onTodayPressed;

  const DayNavigator({
    super.key,
    required this.selectedDate,
    required this.today,
    required this.onPreviousDayPressed,
    required this.onNextDayPressed,
    required this.onTodayPressed,
  });

  bool get isToday =>
      selectedDate.year == today.year &&
      selectedDate.month == today.month &&
      selectedDate.day == today.day;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEEE, MMMM d');
    final shortFormatter = DateFormat('EEE, MMM d');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Previous day button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousDayPressed,
            tooltip: 'Previous day',
          ),

          // Date display with Today indicator if applicable
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    MediaQuery.of(context).size.width > 360
                        ? formatter.format(selectedDate)
                        : shortFormatter.format(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (isToday)
                    Text(
                      'Today',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  if (!isToday)
                    GestureDetector(
                      onTap: onTodayPressed,
                      child: Text(
                        'Go to today',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Next day button (disabled when on current day)
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday ? null : onNextDayPressed,
            tooltip: 'Next day',
            color: isToday
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
