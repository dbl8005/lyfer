import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/utils/helpers/streak_calculator.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';

/// Displays statistics for a habit including streak, completion rate,
/// and progress for the current period
class HabitStatistics extends StatelessWidget {
  const HabitStatistics({
    super.key,
    required this.habit,
  });

  /// The habit to display statistics for
  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    final currentStreak = StreakCalculator.calculateStreak(
        habit.completedDates.toList(), habit.frequency, habit.timesPerPeriod);
    final completionsThisPeriod = habit.getCompletionsInCurrentPeriod();
    final progress = completionsThisPeriod / habit.timesPerPeriod;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  context: context,
                  title: 'Current Streak',
                  value: '$currentStreak',
                  icon: LineIcons.fire,
                  color: Colors.orange,
                ),
                _StatCard(
                  context: context,
                  title: 'Completion',
                  value: '${(progress * 100).toInt()}%',
                  icon: LineIcons.checkCircle,
                  color: Colors.green,
                ),
                _StatCard(
                  context: context,
                  title: 'This ${habit.periodLabel}',
                  value: '$completionsThisPeriod/${habit.timesPerPeriod}',
                  icon: LineIcons.calendarCheck,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card that displays a statistic with an icon, value, and title
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.context,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final BuildContext context;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
