import 'package:flutter/material.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';

class EmptySectionMessage extends StatelessWidget {
  final DaySection section;

  const EmptySectionMessage({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              'No ${section.label.toLowerCase()} habits yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
