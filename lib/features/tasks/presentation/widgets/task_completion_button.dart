import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/config/constants/app_constants.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';

class TaskCompletionButton extends ConsumerWidget {
  final String taskId;
  final bool isCompleted;
  final bool showSnackbar;

  const TaskCompletionButton({
    super.key,
    required this.taskId,
    required this.isCompleted,
    this.showSnackbar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        isCompleted ? Icons.check_circle : Icons.circle_outlined,
        color: isCompleted ? AppTaskColors.completed : AppTaskColors.pending,
      ),
      onPressed: () {
        ref.read(tasksProvider.notifier).toggleTaskCompletion(taskId);

        if (showSnackbar && context.mounted) {
          AppSnackbar.showSuccess(
            context: context,
            message:
                isCompleted ? 'Task marked as incomplete' : 'Task completed!',
          );
        }
      },
    );
  }
}
