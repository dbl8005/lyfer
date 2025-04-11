import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/constants/app_constants.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/shared/widgets/custom_card.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/domain/utils/task_utils.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';

class DashboardTaskItem extends ConsumerWidget {
  final Task task;

  const DashboardTaskItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd');

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: task.color?.withOpacity(0.2) ??
                task.category.defaultColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            task.category.icon,
            size: 20,
            color: task.color ?? task.category.defaultColor,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: task.dueDate != null
            ? Row(
                children: [
                  Icon(
                    LineIcons.calendar,
                    size: 14,
                    color: _getDueDateColor(task.dueDate!),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(task.dueDate!),
                    style: TextStyle(
                      color: _getDueDateColor(task.dueDate!),
                    ),
                  ),
                  if (task.priority.name != 'none') ...[
                    const SizedBox(width: 8),
                    Icon(
                      task.priority.icon,
                      size: 14,
                      color: task.priority.getColor(context),
                    ),
                  ],
                ],
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            ref.read(tasksProvider.notifier).toggleTaskCompletion(task.id!);

            AppSnackbar.showSuccess(
              context: context,
              message: task.isCompleted
                  ? 'Task marked as incomplete'
                  : 'Task completed!',
            );
          },
        ),
        onTap: () => context.push(
          '${AppRouterConsts.taskDetail}/${task.id}',
          extra: task, // Pass the task object as extra data
        ),
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    return TaskUtils.getSimpleDueDateColor(dueDate);
  }
}
