import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
  });

  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
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
          ? Text(habit.description,
              maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${habit.streakCount} days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        // Handle habit tap - perhaps show details or mark as completed
      },
    );
  }
}
