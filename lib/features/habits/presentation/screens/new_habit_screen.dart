import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/core/shared/widgets/form/category_selector.dart';
import 'package:lyfer/core/shared/widgets/form/custom_text_field.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/day_selector.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/habit_color_picker.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/habit_text_field.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/priority_selector.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/reminder_time_picker.dart';

class NewHabitScreen extends ConsumerStatefulWidget {
  const NewHabitScreen({super.key});

  @override
  ConsumerState<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends ConsumerState<NewHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Color? _selectedColor = Colors.grey;
  DaySection _selectedTimeOfDay = DaySection.morning;
  Frequency _selectedFrequency = Frequency.daily;
  int _timesPerPeriod = 1; // Default to 1 time per period
  int? _targetDays;
  Set<WeekDay> _selectedDays = {};
  Priority _selectedPriority = Priority.none;

  Reminder _selectedReminderType = Reminder.none;
  DaySection? _selectedReminderTime;
  TimeOfDay? _specificReminderTime;

  bool _isLoading = false;

  String _selectedCategoryId = 'other';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final habit = HabitModel(
        name: _nameController.text,
        categoryId: _selectedCategoryId,
        createdAt: DateTime.now(),
        color: _selectedColor,
        daySection: _selectedTimeOfDay,
        description: _descriptionController.text,
        frequency: _selectedFrequency,
        timesPerPeriod: _timesPerPeriod,
        targetDays: _targetDays,
        completedDates: {},
        isArchived: false,
        reminderType: _selectedReminderType,
        reminderTime: _selectedReminderTime == null
            ? null
            : TimeOfDay.fromDateTime(DateTime.now()),
        tags: [],
        priority: _selectedPriority,
        notes: [],
        selectedDays: _selectedDays.isEmpty
            ? {
                WeekDay.monday,
                WeekDay.tuesday,
                WeekDay.wednesday,
                WeekDay.thursday,
                WeekDay.friday,
                WeekDay.saturday,
                WeekDay.sunday,
              }
            : _selectedDays,
        isPinned: false,
      );

      await ref.read(habitsProvider.notifier).createHabit(habit);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating habit: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Habit'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveHabit,
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
            // Category selector on its own line
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Habit name field
            CustomFormTextField(
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

            // Rest of your form fields
            const SizedBox(height: 16),
            CustomFormTextField(
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
            _buildTimeSectionPicker(),
            const SizedBox(height: 16),
            _buildFrequencyPicker(),
            const SizedBox(height: 16),
            _buildDaySelector(),
            const SizedBox(height: 16),
            // _buildTargetDaysPicker(),
            // const SizedBox(height: 16),
            _buildPrioritySelector(),
            const SizedBox(height: 16),
            // _buildReminderPicker(),
            // const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSectionPicker() {
    return DropdownButtonFormField<DaySection>(
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
              LineIcon(section.icon),
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
    );
  }

  Widget _buildFrequencyPicker() {
    return Column(
      children: [
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
                // Reset times per period when frequency changes
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
                child: CustomFormTextField(
                  controller:
                      TextEditingController(text: _timesPerPeriod.toString()),
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
      ],
    );
  }

  Widget _buildDaySelector() {
    // Convert Set<WeekDay> to Set<int> using the index values
    final selectedDaysAsInts = _selectedDays.map((day) => day.index).toSet();

    return DaySelector(
      selectedDays: selectedDaysAsInts,
      onDaysSelected: (selectedDays) {
        setState(() {
          _selectedDays =
              selectedDays.map((day) => WeekDay.values[day]).toSet();
        });
      },
      dailyHabit: _selectedFrequency == Frequency.daily,
    );
  }

  Widget _buildTargetDaysPicker() {
    return Column(
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

  // Widget _buildReminderPicker() {
  //   return ReminderTimePicker(
  //     reminderType: _selectedReminderType,
  //     onReminderTypeChanged: (type) {
  //       setState(() {
  //         _selectedReminderType = type;
  //       });
  //     },
  //     reminderTime: _selectedReminderTime,
  //     onReminderTimeChanged: (time) {
  //       setState(() {
  //         _selectedReminderTime = time;
  //       });
  //     },
  //     specificReminderTime: _specificReminderTime,
  //     onSpecificTimeChanged: (time) {
  //       setState(() {
  //         _specificReminderTime = time;
  //       });
  //     },
  //   );
  // }

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
