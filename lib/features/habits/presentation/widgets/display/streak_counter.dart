import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
