import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';

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
                  const Text('The requested task could not be found.'),
                  const SizedBox(height: 20),
                  Text('Task ID: $decodedId'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          );
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
                      content:
                          'Are you sure you want to delete this task? This action cannot be undone.',
                      confirmText: 'Delete',
                      cancelText: 'Cancel',
                      onConfirm: () {
                        // If confirmed, delete the task and navigate back
                        ref.read(tasksProvider.notifier).deleteTask(task.id!);
                        context.pop();
                      });
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (task.description.isNotEmpty) ...[
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(task.description),
                  const SizedBox(height: 16),
                ],
                if (task.dueDate != null) ...[
                  Text(
                    'Due Date:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(dateFormat.format(task.dueDate!)),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        task.isCompleted ? 'Completed' : 'Pending',
                      ),
                      backgroundColor: task.isCompleted
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(tasksProvider.notifier)
                        .toggleTaskCompletion(task.id!);
                  },
                  icon: Icon(
                    task.isCompleted ? Icons.close : Icons.check,
                  ),
                  label: Text(
                    task.isCompleted
                        ? 'Mark as incomplete'
                        : 'Mark as complete',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
