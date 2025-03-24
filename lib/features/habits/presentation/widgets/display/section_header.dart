import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:lyfer/core/config/constants/habit_constants.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';

class SectionHeader extends StatelessWidget {
  final DaySection section;
  final bool isCurrentSection;

  const SectionHeader({
    super.key,
    required this.section,
    this.isCurrentSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentSection
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius:
            BorderRadius.circular(HabitsConstants.sectionCornerRadius),
      ),
      child: Row(
        children: [
          LineIcon(
            section.icon,
            size: 28,
            color: isCurrentSection
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ),
          const SizedBox(width: 12),
          Text(
            section.label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (isCurrentSection) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Now',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
