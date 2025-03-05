// lib/features/habits/presentation/screens/edit_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/habit_color_picker.dart';
import 'package:lyfer/features/habits/presentation/widgets/habit_icon_picker.dart';
import 'package:lyfer/features/habits/presentation/widgets/habit_text_field.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:line_icons/line_icons.dart';

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
  late IconData _selectedIcon;
  late DaySection _selectedTimeOfDay;
  late Frequency _selectedFrequency;
  late int _timesPerPeriod;
  late int? _targetDays;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.habit.name);
    _descriptionController =
        TextEditingController(text: widget.habit.description);

    _selectedColor = widget.habit.color;
    _selectedIcon = HabitIcon.values
        .firstWhere(
          (icon) => icon.name == widget.habit.icon,
          orElse: () => HabitIcon.star,
        )
        .icon;
    _selectedTimeOfDay = widget.habit.preferredTime;
    _selectedFrequency = widget.habit.frequency;
    _timesPerPeriod = widget.habit.timesPerPeriod;
    _targetDays = widget.habit.targetDays;
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

    final selectedIconName = HabitIcon.values
        .firstWhere((habitIcon) => habitIcon.icon == _selectedIcon)
        .name;

    try {
      final updatedHabit = widget.habit.copyWith(
        name: _nameController.text,
        iconName: selectedIconName,
        color: _selectedColor,
        preferredTime: _selectedTimeOfDay,
        description: _descriptionController.text,
        frequency: _selectedFrequency,
        timesPerPeriod: _timesPerPeriod,
        targetDays: _targetDays,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        actions: [
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HabitIconPicker(
                  selectedIcon: _selectedIcon,
                  onIconSelected: (icon) {
                    setState(() => _selectedIcon = icon);
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: HabitTextField(
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
                ),
              ],
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
                      Text(section.displayText),
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
          ],
        ),
      ),
    );
  }
}
