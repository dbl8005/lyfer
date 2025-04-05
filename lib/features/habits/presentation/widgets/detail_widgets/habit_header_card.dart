import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/display/active_days_indicator.dart';
import 'package:lyfer/features/habits/presentation/widgets/shared/info_row.dart';

/// A card that displays the header information about a habit
/// including its name, icon, description, and metadata
class HabitHeaderCard extends StatelessWidget {
  const HabitHeaderCard({
    super.key,
    required this.habit,
  });

  /// The habit model to display information for
  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWithIcon(context),
            if (habit.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                habit.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 16),
            InfoRow(
              icon: LineIcons.calendar,
              label: 'Frequency',
              value: _getFrequencyText(),
            ),
            const SizedBox(height: 8),
            InfoRow(
              icon: LineIcons.clock,
              label: 'Preferred Time',
              value: habit.daySection.label,
            ),
            if (habit.selectedDays.isNotEmpty &&
                habit.selectedDays.length < 7) ...[
              const SizedBox(height: 8),
              ActiveDaysIndicator(
                  selectedDays: habit.selectedDays, frequency: habit.frequency),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the header row with habit icon and name
  Widget _buildHeaderWithIcon(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: habit.color ?? habit.category.defaultColor,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            habit.category.icon,
            size: 40,
            color: habit.color ?? habit.category.defaultColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              _buildPriorityBadge(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a badge to display the priority level, if applicable
  Widget _buildPriorityBadge(BuildContext context) {
    if (habit.priority.name == 'none') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: habit.priority.getColor(context).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            habit.priority.icon,
            size: 16,
            color: habit.priority.getColor(context),
          ),
          const SizedBox(width: 4),
          Text(
            habit.priority.label,
            style: TextStyle(
              color: habit.priority.getColor(context),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the formatted frequency text
  String _getFrequencyText() {
    final formattedName = _formatEnumName(habit.frequency.name);
    if (habit.frequency == Frequency.daily) {
      return formattedName;
    }
    return '$formattedName (${habit.timesPerPeriod} times per ${habit.frequency.label})';
  }

  /// Formats an enum name to be more readable
  /// e.g. 'DAILY_CHALLENGE' -> 'Daily Challenge'
  String _formatEnumName(String name) {
    return name
        .split('.')
        .last
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Converts a set of day indices to a readable string
  /// e.g. [0, 1, 3] -> 'Sun, Mon, Wed'
  String _getWeekdaysText(Set<int> days) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days.map((day) => weekdays[day]).join(', ');
  }
}
