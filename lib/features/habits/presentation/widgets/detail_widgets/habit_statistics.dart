import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/utils/helpers/streak_calculator.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';

/// Displays statistics for a habit including streak, completion rate,
/// and progress for the current period
class HabitStatistics extends StatefulWidget {
  const HabitStatistics({
    super.key,
    required this.habit,
  });

  /// The habit to display statistics for
  final HabitModel habit;

  @override
  State<HabitStatistics> createState() => _HabitStatisticsState();
}

class _HabitStatisticsState extends State<HabitStatistics> {
  @override
  Widget build(BuildContext context) {
    final streak = widget.habit.streakCount;
    final bestStreak = widget.habit.bestStreak;

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
                  value: '$streak',
                  icon: LineIcons.fire,
                  color: Colors.orange,
                ),
                _StatCard(
                  context: context,
                  title: 'Best Streak',
                  value: '$bestStreak',
                  icon: LineIcons.trophy,
                  color: Colors.yellow,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// A card that displays a statistic with an icon, value, and title
class _StatCard extends StatefulWidget {
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
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(widget.icon, color: widget.color, size: 30),
        const SizedBox(height: 8),
        Text(
          widget.value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
        ),
        Text(
          widget.title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
