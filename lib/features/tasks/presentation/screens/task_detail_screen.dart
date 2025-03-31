import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/domain/utils/task_utils.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/tasks/presentation/widgets/detail_card.dart';
import 'package:lyfer/features/tasks/presentation/widgets/task_due_date_badge.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header card with core details
              _buildTaskHeaderCard(),
              const SizedBox(height: 20),

              // Due date section
              if (widget.task.dueDate != null) ...[
                _buildDueDateSection(),
                const SizedBox(height: 20),
              ],

              // Description section - full width
              _buildDescriptionSection(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.task.title),
      actions: [
        IconButton(
          icon: const Icon(LineIcons.pen),
          tooltip: 'Edit task',
          onPressed: () =>
              context.push('/tasks/edit/${widget.task.id}', extra: widget.task),
        ),
        IconButton(
          icon: const Icon(LineIcons.trash),
          tooltip: 'Delete task',
          color: Colors.red,
          onPressed: _deleteTask,
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Toggle task completion status
        final taskProvider = ref.read(tasksProvider.notifier);
        taskProvider.updateTask(
          widget.task.copyWith(isCompleted: !widget.task.isCompleted),
        );

        AppSnackbar.show(
          context: context,
          message: widget.task.isCompleted
              ? 'Task marked as incomplete'
              : 'Task completed!',
          backgroundColor:
              widget.task.isCompleted ? Colors.orange : Colors.green,
        );

        // Close the screen after toggling
        context.pop();
      },
      tooltip: widget.task.isCompleted ? 'Mark incomplete' : 'Mark complete',
      child: Icon(widget.task.isCompleted ? LineIcons.times : LineIcons.check),
    );
  }

  Widget _buildTaskHeaderCard() {
    return DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status badge row
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.task.isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.task.isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(
                    color:
                        widget.task.isCompleted ? Colors.green : Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category and priority info
          Row(
            children: [
              Icon(widget.task.iconData, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.task.category.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(LineIcons.flag, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.task.priority.name.toUpperCase(),
                style: TextStyle(
                  color: _getPriorityColor(widget.task.priority),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateSection() {
    return DetailCard(
      title: 'Due Date',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LineIcons.calendar,
                color: _getDueDateColor(widget.task.dueDate!, context),
              ),
              const SizedBox(width: 12),
              Text(
                DateFormat('EEEE, MMMM d, y').format(widget.task.dueDate!),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _getDueDateColor(widget.task.dueDate!, context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDueDateStatus(widget.task.dueDate!),
            style: TextStyle(
              color: _getDueDateColor(widget.task.dueDate!, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return DetailCard(
      title: 'Description',
      child: SizedBox(
        width: double.infinity,
        child: Text(
          widget.task.description.isEmpty
              ? 'No description provided'
              : widget.task.description,
          style: TextStyle(
            fontStyle: widget.task.description.isEmpty
                ? FontStyle.italic
                : FontStyle.normal,
            color: widget.task.description.isEmpty
                ? Theme.of(context).colorScheme.outline
                : null,
          ),
        ),
      ),
    );
  }

  String _getDueDateStatus(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative && !widget.task.isCompleted) {
      return 'Overdue by ${-difference.inDays} day(s)';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else {
      return 'Due in ${difference.inDays} day(s)';
    }
  }

  Color _getPriorityColor(dynamic priority) {
    switch (priority.toString()) {
      case 'Priority.high':
        return Colors.red;
      case 'Priority.medium':
        return Colors.orange;
      case 'Priority.low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getDueDateColor(DateTime dueDate, BuildContext context) {
    return TaskUtils.getDueDateColor(dueDate, context);
  }

  Future<void> _deleteTask() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Task',
      content: 'Are you sure you want to delete this task?',
      confirmText: 'DELETE',
    );

    if (confirmed == true) {
      try {
        await ref.read(tasksProvider.notifier).deleteTask(widget.task.id!);
        if (mounted) {
          AppSnackbar.show(
            context: context,
            message: 'Task deleted successfully',
            backgroundColor: Colors.green,
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.show(
            context: context,
            message: 'Failed to delete task: $e',
            backgroundColor: Colors.red,
          );
        }
      }
    }
  }
}
