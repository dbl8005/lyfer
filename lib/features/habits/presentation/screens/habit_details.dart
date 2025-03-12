import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icon.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';

class HabitDetails extends ConsumerWidget {
  const HabitDetails({super.key, required this.habit});
  final HabitModel habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Details'),
        actions: [
          // IconButton(
          // onPressed: () {
          //   // Handle edit action
          //   context.go(
          //     '${AppRouterConsts.habitEdit}/${habit.id}',
          //     extra: habit,
          //   );
          // },
          // icon: const Icon(Icons.edit),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit icon and name
            Row(
              children: [
                // Placeholder for habit icon
                habit.icon != null
                    ? LineIcon(
                        HabitIcon.values
                            .firstWhere((e) => e.name == habit.icon)
                            .icon,
                        size: 40,
                      )
                    : const Icon(
                        Icons.check_circle_outline,
                        size: 40,
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${habit.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Habit details
            Text(
              '${habit.description}',
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Habit frequency
            Text(
              'Frequency: ${habit.frequency.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // Habit Streak
            Text(
              'Current Streak: ${habit.streakCount}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
