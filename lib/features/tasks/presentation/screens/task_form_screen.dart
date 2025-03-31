import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/constants/app_constants.dart';
import 'package:lyfer/core/shared/models/category_model.dart';
import 'package:lyfer/core/shared/widgets/form/category_selector.dart';
import 'package:lyfer/core/shared/widgets/form/custom_text_field.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/priority_selector.dart';
import 'package:lyfer/features/tasks/domain/enums/task_enums.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isCompleted = false;
  bool _isSubmitting = false;
  bool _isLoading = true;
  Task? _task;

  // New properties for category and priority
  Priority _selectedPriority = Priority.none;
  Color? _selectedColor = Colors.grey;
  String _selectedCategoryId = 'other';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    // Initialize form values after getting the task
    if (widget.taskId != null) {
      _loadTask();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadTask() async {
    final tasksAsync = await ref.read(tasksStreamProvider.future);
    final task = tasksAsync.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => Task(title: ''),
    );

    if (mounted) {
      setState(() {
        _task = task;
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _dueDate = task.dueDate;
        _isCompleted = task.isCompleted;
        _selectedCategoryId = task.categoryId;
        _selectedPriority = task.priority;
        _selectedColor = task.color;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final task = Task(
          id: _task?.id, // Pass the id if it's an update
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          isCompleted: _isCompleted,
          categoryId: _selectedCategoryId,
          priority: _selectedPriority,
          color: _selectedColor,
          createdAt: _task?.createdAt,
        );

        if (_task == null) {
          await ref.read(tasksProvider.notifier).addTask(task);
        } else {
          await ref.read(tasksProvider.notifier).updateTask(task);
        }

        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _task != null;
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Task' : 'New Task'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const LineIcon.check(),
            onPressed: _isSubmitting ? null : _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCategorySelector(),
                const SizedBox(height: 16),
                CustomFormTextField(
                    controller: _titleController, label: 'Title'),
                const SizedBox(height: 16),
                CustomFormTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  isMultiline: true,
                  hint: 'Enter task description',
                ),
                const SizedBox(height: 16),
                _buildPrioritySelector(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return PrioritySelector(
      selectedPriority: _selectedPriority,
      onPriorityChanged: (priority) {
        setState(() {
          _selectedPriority = priority;
        });
      },
    );
  }

  Widget _buildCategorySelector() {
    return CategorySelector(
      selectedCategoryId: _selectedCategoryId,
      onCategorySelected: (categoryId) {
        setState(() {
          _selectedCategoryId = categoryId;
        });
      },
      onColorSelected: (color) {
        setState(() {
          _selectedColor = color;
        });
      },
    );
  }
}
