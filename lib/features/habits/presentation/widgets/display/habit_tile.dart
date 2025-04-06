import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/core/shared/widgets/custom_card.dart';
import 'package:lyfer/core/shared/widgets/circular_icon.dart';
import 'package:lyfer/core/shared/widgets/responsive_padding.dart';
import 'package:lyfer/core/shared/widgets/status_indicator.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';
import 'package:lyfer/features/habits/presentation/widgets/display/streak_counter.dart';

class HabitTile extends ConsumerWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.selectedDate,
  });

  final HabitModel habit;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCompletedForDate = habit.isCompletedForDate(selectedDate);
    final currentStreak = _calculateCurrentStreak(ref);

    return CustomCard(
      margin: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 300;

          return ResponsivePadding(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _buildLeadingIcon(context, isNarrow),
              title: _buildTitle(context, theme),
              subtitle: _buildSubtitle(theme),
              trailing: _buildTrailing(
                  context, ref, isNarrow, isCompletedForDate, currentStreak),
              onTap: () => _navigateToHabitDetails(context),
            ),
          );
        },
      ),
    );
  }

  // Calculate current streak
  int _calculateCurrentStreak(WidgetRef ref) {
    final streakCalculator =
        ref.read(habitsRepositoryProvider.notifier).getStreakForHabit(habit);
    return streakCalculator;
  }

  // Leading icon with category
  Widget _buildLeadingIcon(BuildContext context, bool isNarrow) {
    return CircularIcon(
      icon: habit.category.icon,
      color: habit.color ?? habit.category.defaultColor,
      size: isNarrow ? 36 : 44,
      iconSize: isNarrow ? 20 : 24,
    );
  }

  // Title with priority indicator
  Widget _buildTitle(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        StatusIndicator(
          icon: habit.priority.icon,
          color: habit.priority.getColor(context),
          tooltip: 'Priority: ${habit.priority.name}',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            habit.name,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // Subtitle with description and indicators
  Widget _buildSubtitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (habit.description.isNotEmpty)
          Text(
            habit.description,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        // Progress indicators can be uncommented when needed
        // _buildProgressIndicator(theme),
        // _buildActiveDaysIndicator(),
      ],
    );
  }

  // Trailing with streak, menu and completion button
  Widget _buildTrailing(BuildContext context, WidgetRef ref, bool isNarrow,
      bool isCompletedForDate, int currentStreak) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Streak counter
        StreakCounter(currentStreak: currentStreak),

        // More options menu
        _buildOptionsMenu(context, ref, isNarrow),

        // Completion button
        _buildCompletionButton(ref, isNarrow, isCompletedForDate),
      ],
    );
  }

  // Options menu (edit/delete)
  Widget _buildOptionsMenu(BuildContext context, WidgetRef ref, bool isNarrow) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: isNarrow ? 20 : 24),
      onSelected: (value) => _handleMenuSelection(context, ref, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(LineIcons.pen),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(LineIcons.trash),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  // Handle menu item selection
  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'edit':
        context.push('${AppRouterConsts.habitEdit}/${habit.id}', extra: habit);
        break;
      case 'delete':
        ConfirmDialog.show(
          context: context,
          title: 'Delete Habit',
          content: 'Are you sure you want to delete this habit?',
          onConfirm: () {
            ref.read(habitsRepositoryProvider).deleteHabit(habit.id!);
            Navigator.of(context).pop();
          },
        );
        break;
    }
  }

  // Completion toggle button
  Widget _buildCompletionButton(
      WidgetRef ref, bool isNarrow, bool isCompletedForDate) {
    return IconButton(
      icon: Icon(
        isCompletedForDate ? Icons.check_circle : Icons.circle_outlined,
        color: isCompletedForDate ? Colors.green : Colors.grey,
        size: isNarrow ? 20 : 24,
      ),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      onPressed: () => _toggleHabitCompletion(ref),
    );
  }

  // Toggle habit completion
  void _toggleHabitCompletion(WidgetRef ref) {
    ref
        .read(habitsRepositoryProvider)
        .toggleHabitCompletion(habit.id!, selectedDate);
  }

  // Navigate to habit details
  void _navigateToHabitDetails(BuildContext context) {
    context.push(
      '${AppRouterConsts.habitDetails}/${habit.id}',
      extra: habit,
    );
  }
}
