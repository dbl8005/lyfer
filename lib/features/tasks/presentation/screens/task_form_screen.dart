import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
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
  DateTime? _dueDate;
  bool _isCompleted = false;
  bool _isSubmitting = false;
  bool _isLoading = true;
  Task? _task;

  // New properties for category and priority
  TaskCategory _selectedCategory = TaskCategory.other;
  TaskPriority _selectedPriority = TaskPriority.none;
  Color? _selectedColor;

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
        _selectedCategory = task.category;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectColor(BuildContext context) async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a color'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              children: [
                ...[
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                ].map((Color color) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(color);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                // Add a clear option
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(null);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(
                      child: Icon(Icons.clear, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (pickedColor != _selectedColor && mounted) {
      setState(() {
        _selectedColor = pickedColor;
      });
    }
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
          category: _selectedCategory,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date (optional)',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dueDate == null
                              ? 'No date selected'
                              : dateFormat.format(_dueDate!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Dropdown
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TaskCategory>(
                      value: _selectedCategory,
                      isExpanded: true,
                      onChanged: (TaskCategory? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                      items: TaskCategory.values.map((TaskCategory category) {
                        return DropdownMenuItem<TaskCategory>(
                          value: category,
                          child: Row(
                            children: [
                              LineIcon(
                                category.icon,
                                size: 20,
                                color: category.defaultColor,
                              ),
                              const SizedBox(width: 8),
                              Text(category.label),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Priority Dropdown
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TaskPriority>(
                      value: _selectedPriority,
                      isExpanded: true,
                      onChanged: (TaskPriority? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriority = newValue;
                          });
                        }
                      },
                      items: TaskPriority.values.map((TaskPriority priority) {
                        return DropdownMenuItem<TaskPriority>(
                          value: priority,
                          child: Row(
                            children: [
                              Icon(
                                priority.icon,
                                size: 20,
                                color: priority.color,
                              ),
                              const SizedBox(width: 8),
                              Text(priority.label),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Color Picker
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectColor(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Custom Color (optional)',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedColor == null
                              ? 'Default color'
                              : 'Custom color',
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _selectedColor ??
                                _selectedCategory.defaultColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (isEditing) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Completed'),
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Save Changes' : 'Add Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
