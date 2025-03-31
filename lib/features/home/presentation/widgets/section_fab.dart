import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/features/home/constants/home_constants.dart';

/// Factory for creating section-specific floating action buttons
class SectionFAB extends StatelessWidget {
  final int currentSectionIndex;

  const SectionFAB({
    super.key,
    required this.currentSectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Only show FAB for habits and tasks sections
    if (currentSectionIndex == HomeConstants.habitsIndex) {
      return _buildHabitFAB(context);
    } else if (currentSectionIndex == HomeConstants.tasksIndex) {
      return _buildTaskFAB(context);
    }

    // Return null for other sections (no FAB)
    return const SizedBox.shrink();
  }

  FloatingActionButton _buildHabitFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push(AppRouterConsts.newHabit),
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }

  FloatingActionButton _buildTaskFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push(AppRouterConsts.newTask),
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }
}
