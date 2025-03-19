// lib/features/habits/presentation/screens/edit_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/category_selector.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/habit_color_picker.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/habit_text_field.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/priority_selector.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/reminder_time_picker.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final HabitModel habit;

  const EditHabitScreen({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late Color? _selectedColor;
  // Remove _selectedIcon as it's no longer used
  late DaySection _selectedTimeOfDay;
  late Frequency _selectedFrequency;
  late int _timesPerPeriod;
  late int? _targetDays;
  late Set<int> _selectedDays;

  late Priority _selectedPriority;
  late String _selectedCategoryId;
  late Reminder _selectedReminderType;
  late DaySection? _selectedReminderTime;
  late TimeOfDay? _specificReminderTime;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.habit.name);
    _descriptionController =
        TextEditingController(text: widget.habit.description);

    _selectedColor = widget.habit.color;
    // Remove the _selectedIcon initialization which uses the old system
    _selectedTimeOfDay = widget.habit.preferredTime;
    _selectedFrequency = widget.habit.frequency;
    _timesPerPeriod = widget.habit.timesPerPeriod;
    _targetDays = widget.habit.targetDays;

    // Make sure _selectedDays is properly initialized with a default if needed
    _selectedDays = widget.habit.selectedDays.isNotEmpty
        ? widget.habit.selectedDays
        : (_selectedFrequency == Frequency.daily ? {0, 1, 2, 3, 4, 5, 6} : {});

    _selectedPriority = widget.habit.priority;
    _selectedCategoryId = widget.habit.categoryId;
    _selectedReminderType = widget.habit.reminderType;
    _selectedReminderTime = widget.habit.reminderTime;
    _specificReminderTime = widget.habit.specificReminderTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Update habit
  Future<void> _updateHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedHabit = widget.habit.copyWith(
        name: _nameController.text,
        categoryId: _selectedCategoryId, // Changed from iconName
        color: _selectedColor,
        preferredTime: _selectedTimeOfDay,
        description: _descriptionController.text,
        frequency: _selectedFrequency,
        timesPerPeriod: _timesPerPeriod,
        targetDays: _targetDays,
        selectedDays: _selectedDays, // Add selected days
        priority: _selectedPriority, // Add priority
        reminderType: _selectedReminderType, // Add reminder type
        reminderTime: _selectedReminderTime, // Add reminder time
        specificReminderTime: _specificReminderTime, // Add specific time
      );

      await ref.read(habitServiceProvider).updateHabit(updatedHabit);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.show(
          context: context,
          message: 'Habit updated successfully!',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          message: 'Failed to update habit: $e',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Delete habit with confirmation
  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text(
            'Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(habitServiceProvider).deleteHabit(widget.habit.id!);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.show(
          context: context,
          message: 'Habit deleted successfully',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          message: 'Failed to delete habit: $e',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatEnumName(String name) {
    return name
        .split('.')
        .last
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Days:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            final isSelected = _selectedDays.contains(index);
            return FilterChip(
              label: Text(dayNames[index]),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  // For daily habits, we always need at least one day selected
                  if (_selectedFrequency == Frequency.daily &&
                      _selectedDays.length == 1 &&
                      _selectedDays.contains(index)) {
                    return;
                  }

                  if (_selectedDays.contains(index)) {
                    _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                });
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          }),
        ),
      ],
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

  Widget _buildReminderPicker() {
    return ReminderTimePicker(
      reminderType: _selectedReminderType,
      onReminderTypeChanged: (type) {
        setState(() {
          _selectedReminderType = type;
        });
      },
      reminderTime: _selectedReminderTime,
      onReminderTimeChanged: (time) {
        setState(() {
          _selectedReminderTime = time;
        });
      },
      specificReminderTime: _specificReminderTime,
      onSpecificTimeChanged: (time) {
        setState(() {
          _specificReminderTime = time;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        actions: [
          // Delete button
          IconButton(
            icon: const LineIcon(
              LineIcons.trash,
              color: Colors.red,
            ),
            onPressed: _isLoading ? null : _deleteHabit,
          ),
          // Save button
          IconButton(
            onPressed: _isLoading ? null : _updateHabit,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Replace existing icon picker with category selector
            _buildCategorySelector(),
            const SizedBox(height: 16),
            HabitTextField(
              controller: _nameController,
              label: 'Habit Name',
              hint: 'Enter habit name',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a habit name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            HabitTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter habit description',
              isMultiline: true,
            ),
            const SizedBox(height: 16),
            HabitColorPicker(
              selectedColor: _selectedColor,
              onColorChanged: (color) {
                setState(() => _selectedColor = color);
              },
            ),
            const SizedBox(height: 16),
            // Time section picker
            DropdownButtonFormField<DaySection>(
              value: _selectedTimeOfDay,
              decoration: const InputDecoration(
                labelText: 'Preferred Time',
                border: OutlineInputBorder(),
              ),
              items: DaySection.values.map((section) {
                return DropdownMenuItem(
                  value: section,
                  child: Row(
                    children: [
                      Icon(section.icon),
                      const SizedBox(width: 8),
                      Text(section.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTimeOfDay = value);
                }
              },
            ),
            const SizedBox(height: 16),
            // Frequency picker
            DropdownButtonFormField<Frequency>(
              value: _selectedFrequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: Frequency.values.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(_formatEnumName(frequency.toString())),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFrequency = value;
                    if (value == Frequency.daily) {
                      _timesPerPeriod = 1;
                    }
                  });
                }
              },
            ),
            if (_selectedFrequency != Frequency.daily) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Times per ${_selectedFrequency == Frequency.weekly ? 'week' : 'month'}:',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: HabitTextField(
                      controller: TextEditingController(
                          text: _timesPerPeriod.toString()),
                      label: '',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return 'Min 1';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final number = int.tryParse(value);
                        if (number != null && number > 0) {
                          setState(() {
                            _timesPerPeriod = number;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _buildDaySelector(),
            const SizedBox(height: 16),
            // Target days picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Set Target Days'),
                  value: _targetDays != null,
                  onChanged: (value) {
                    setState(() => _targetDays = value ? 21 : null);
                  },
                ),
                if (_targetDays != null) ...[
                  Row(
                    children: [
                      const Text('Target Days:'),
                      Expanded(
                        child: Slider(
                          value: _targetDays!.toDouble(),
                          min: 1,
                          max: 90,
                          divisions: 89,
                          label: _targetDays.toString(),
                          onChanged: (value) {
                            setState(() => _targetDays = value.round());
                          },
                        ),
                      ),
                      Text(_targetDays.toString()),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildPrioritySelector(),
            const SizedBox(height: 16),
            _buildReminderPicker(),
          ],
        ),
      ),
    );
  }
}
