import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/constants/app_constants.dart';
import 'package:lyfer/core/config/constants/ui_constants.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/core/widgets/custom_card.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:lyfer/features/tasks/domain/enums/task_enums.dart';
import 'package:lyfer/features/tasks/presentation/widgets/task_due_date_badge.dart';

class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: UIConstants.smallSpacing),
      child: ListTile(
        contentPadding: UIConstants.paddingAllS,
        leading: _buildCategoryIcon(),
        title: _buildTaskTitle(context),
        subtitle: _buildTaskSubtitle(context, dateFormat),
        trailing: _buildTaskActions(context, ref),
        onTap: () {
          context.push('${AppRouterConsts.taskDetail}/${task.id}');
        },
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      padding: UIConstants.paddingAllS,
      decoration: BoxDecoration(
        border: Border.all(
          color: task.color ?? task.category.defaultColor,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: LineIcon(
        task.category.icon,
        size: 24,
        color: task.color ?? task.category.defaultColor,
      ),
    );
  }

  Widget _buildTaskTitle(BuildContext context) {
    return Row(
      children: [
        if (task.priority != TaskPriority.none)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: task.priority.getColor(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
            ),
            child: Icon(
              task.priority.icon,
              size: 16,
              color: task.priority.getColor(context),
            ),
          ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            task.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSubtitle(BuildContext context, DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.description.isNotEmpty)
          Text(
            task.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (task.dueDate != null)
          TaskDueDateBadge(dueDate: task.dueDate!, dateFormat: dateFormat),
      ],
    );
  }

  Widget _buildTaskActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                context.push('${AppRouterConsts.taskDetail}/${task.id}');
                break;
              case 'delete':
                // Show confirmation dialog before deleting
                ConfirmDialog.show(
                        context: context,
                        content: 'Are you sure you want to delete this task?')
                    .then((value) {
                  if (value == true) {
                    ref.read(tasksProvider.notifier).deleteTask(task.id!);
                    AppSnackbar.showSuccess(
                        context: context,
                        message: '${task.title} deleted successfully');
                  }
                });
                break;
            }
          },
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
        ),
        IconButton(
          icon: Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted
                ? AppTaskColors.completed
                : AppTaskColors.pending,
          ),
          onPressed: () {
            ref.read(tasksProvider.notifier).toggleTaskCompletion(task.id!);
          },
        ),
      ],
    );
  }
}
