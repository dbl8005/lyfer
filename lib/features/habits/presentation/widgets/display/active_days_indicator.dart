import 'package:flutter/material.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';

/// A widget that visually displays which days of the week a habit is active
///
/// Shows a row of day indicators (M, T, W, T, F, S, S) with the selected days
/// highlighted, making it easy to see the habit's weekly schedule at a glance.
class ActiveDaysIndicator extends StatelessWidget {
  /// List of day indices that are selected (0 = Monday, 6 = Sunday)
  final List<int> selectedDays;

  /// Frequency of the habit, used to determine when to hide the indicator
  final Frequency frequency;

  /// Optional custom color for the selected day indicators
  final Color? selectedColor;

  /// Optional custom color for the unselected day indicators
  final Color? unselectedColor;

  /// Size of the day indicators (default: 14)
  final double size;

  /// Day labels to display
  static const List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const ActiveDaysIndicator({
    super.key,
    required this.selectedDays,
    required this.frequency,
    this.selectedColor,
    this.unselectedColor,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    // Hide if no days are selected or if habit is daily with all days selected
    if (selectedDays.isEmpty ||
        (frequency == Frequency.daily && selectedDays.length == 7)) {
      return const SizedBox.shrink();
    }

    final selectedBgColor =
        selectedColor ?? Theme.of(context).colorScheme.primaryContainer;

    final unselectedBgColor =
        unselectedColor ?? Theme.of(context).colorScheme.surfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: size - 2,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          ...List.generate(7, (index) {
            final isSelected = selectedDays.contains(index);
            return Container(
              width: size,
              height: size,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? selectedBgColor : unselectedBgColor,
              ),
              child: Center(
                child: Text(
                  dayLabels[index],
                  style: TextStyle(
                    fontSize: size - 4,
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
