import 'package:flutter/material.dart';

/// Displays a message and call-to-action when no habits are available
class EmptyHabitsView extends StatelessWidget {
  final VoidCallback? onCreateHabit;

  const EmptyHabitsView({
    super.key,
    this.onCreateHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_nature,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first habit by tapping the + button below',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (onCreateHabit != null)
            ElevatedButton.icon(
              onPressed: onCreateHabit,
              icon: const Icon(Icons.add),
              label: const Text('Create Habit'),
            ),
        ],
      ),
    );
  }
}
