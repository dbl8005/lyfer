import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';

class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Dismissible(
      key: Key(task.id!),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(tasksProvider.notifier).deleteTask(task.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${task.title} dismissed')),
        );
      },
      child: Card(
        color: task.isCompleted
            ? Colors.grey.withOpacity(0.4)
            : Theme.of(context).colorScheme.surface,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: task.isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: LineIcon(
              task.isCompleted ? LineIcons.checkCircle : LineIcons.tasks,
              size: 24,
              color: task.isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          subtitle: Column(
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
                Row(
                  children: [
                    LineIcon(
                      LineIcons.calendar,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${dateFormat.format(task.dueDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getDueDateColor(task.dueDate!, context),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          trailing: Row(
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
                      ref.read(tasksProvider.notifier).deleteTask(task.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${task.title} deleted')),
                      );
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
                  color: task.isCompleted ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  ref
                      .read(tasksProvider.notifier)
                      .toggleTaskCompletion(task.id!);
                },
              ),
            ],
          ),
          onTap: () {
            context.push('${AppRouterConsts.taskDetail}/${task.id}');
          },
        ),
      ),
    );
  }

  // Helper method to determine due date color based on urgency
  Color _getDueDateColor(DateTime dueDate, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference == 0) {
      return Colors.orange; // Due today
    } else if (difference <= 2) {
      return Colors.amber; // Due soon
    }
    return Theme.of(context).colorScheme.onSurfaceVariant; // Normal
  }
}
