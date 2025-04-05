import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';

class DashboardHabitItem extends ConsumerWidget {
  final HabitModel habit;

  const DashboardHabitItem({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = habit.isCompletedToday();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: habit.color ?? habit.category.defaultColor,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            habit.category.icon,
            size: 20,
            color: habit.color ?? habit.category.defaultColor,
          ),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: habit.description.isNotEmpty
            ? Text(
                habit.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (habit.priority.name != 'none')
              Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: habit.priority.getColor(context).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  habit.priority.icon,
                  size: 14,
                  color: habit.priority.getColor(context),
                ),
              ),
            IconButton(
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleCompletion(context, ref),
            ),
          ],
        ),
        onTap: () => context.push(
          '${AppRouterConsts.habitDetails}/${habit.id}',
          extra: habit,
        ),
      ),
    );
  }

  Future<void> _toggleCompletion(BuildContext context, WidgetRef ref) async {
    try {
      final isCompleted = habit.isCompletedToday();
      await ref.read(habitsProvider.notifier).toggleHabitCompletion(
            habit.id!,
            DateTime.now(),
          );

      if (context.mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message:
              isCompleted ? 'Habit marked as incomplete' : 'Habit completed!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to update habit: $e',
        );
      }
    }
  }
}
