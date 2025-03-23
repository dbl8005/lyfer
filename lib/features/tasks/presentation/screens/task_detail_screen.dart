import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/features/tasks/domain/enums/task_enums.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return tasksAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (tasks) {
        // Make sure to decode the taskId if it was encoded in the URL
        final String decodedId = Uri.decodeComponent(taskId);
        final taskIndex = tasks.indexWhere((t) => t.id == decodedId);

        // If task not found, show error
        if (taskIndex == -1) {
          return _buildTaskNotFoundScreen(context, decodedId);
        }

        final task = tasks[taskIndex];
        final dateFormat = DateFormat('MMMM dd, yyyy');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context
                    .push('/tasks/edit/${Uri.encodeComponent(task.id!)}'),
              ),
              IconButton(
                icon: const LineIcon(
                  LineIcons.trash,
                  color: Colors.red,
                ),
                onPressed: () {
                  // Show a confirmation dialog before deleting
                  ConfirmDialog.show(
                      context: context,
                      title: 'Delete Task',
                      content:
                          'Are you sure you want to delete this task? This action cannot be undone.',
                      confirmText: 'Delete',
                      cancelText: 'Cancel',
                      onConfirm: () {
                        // If confirmed, delete the task and navigate back
                        ref.read(tasksProvider.notifier).deleteTask(task.id!);
                        context.pop();
                        // Show feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${task.title} deleted')),
                        );
                      });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with task title and completion status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon in circle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: task.color ?? task.category.defaultColor,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: LineIcon(
                        task.category.icon,
                        size: 32,
                        color: task.color ?? task.category.defaultColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Category label
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      (task.color ?? task.category.defaultColor)
                                          .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.category.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: task.color ??
                                        task.category.defaultColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Priority label if it's not none
                              if (task.priority != TaskPriority.none)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: task.priority
                                        .getColor(context)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        task.priority.icon,
                                        size: 12,
                                        color: task.priority.getColor(context),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.priority.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              task.priority.getColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: 8),
                              // Status chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: task.isCompleted
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.isCompleted ? 'Completed' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: task.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Task metadata
                _buildInfoCard(
                  context,
                  [
                    if (task.description.isNotEmpty)
                      _buildInfoRow(
                        context,
                        LineIcons.alignLeft,
                        'Description',
                        task.description,
                      ),
                    if (task.dueDate != null)
                      _buildInfoRow(
                        context,
                        LineIcons.calendar,
                        'Due Date',
                        dateFormat.format(task.dueDate!),
                        task.dueDate != null
                            ? _getDueDateColor(task.dueDate!, context)
                            : null,
                      ),
                    _buildInfoRow(
                      context,
                      LineIcons.clock,
                      'Created',
                      dateFormat.format(task.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskNotFoundScreen(BuildContext context, String decodedId) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LineIcon(
              LineIcons.questionCircle,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Task Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('The requested task could not be found.'),
            const SizedBox(height: 8),
            Text(
              'Task ID: $decodedId',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(LineIcons.home),
              label: const Text('Go Home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value,
      [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
              ),
            ),
          ),
        ],
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
    return Theme.of(context).colorScheme.onSurface; // Normal
  }
}
