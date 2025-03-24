import 'package:flutter/material.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';

class ReminderTimePicker extends StatefulWidget {
  final Reminder reminderType;
  final ValueChanged<Reminder> onReminderTypeChanged;
  final DaySection? reminderTime;
  final ValueChanged<DaySection?> onReminderTimeChanged;
  final TimeOfDay? specificReminderTime;
  final ValueChanged<TimeOfDay?> onSpecificTimeChanged;

  const ReminderTimePicker({
    super.key,
    required this.reminderType,
    required this.onReminderTypeChanged,
    required this.reminderTime,
    required this.onReminderTimeChanged,
    required this.specificReminderTime,
    required this.onSpecificTimeChanged,
  });

  @override
  State<ReminderTimePicker> createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.specificReminderTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != widget.specificReminderTime) {
      widget.onSpecificTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        // Reminder type selection
        Wrap(
          spacing: 8,
          children: Reminder.values.map((type) {
            return ChoiceChip(
              label: Text(type.label),
              selected: type == widget.reminderType,
              onSelected: (_) => widget.onReminderTypeChanged(type),
            );
          }).toList(),
        ),

        // Show additional options based on reminder type
        if (widget.reminderType != Reminder.none) ...[
          const SizedBox(height: 16),
          Text('When to remind?', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),

          // Option 1: Select day section
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: widget.specificReminderTime == null,
                onChanged: (value) {
                  if (value == true) {
                    widget.onSpecificTimeChanged(null);
                    if (widget.reminderTime == null) {
                      widget.onReminderTimeChanged(DaySection.morning);
                    }
                  }
                },
              ),
              const Text('Day section'),
            ],
          ),

          if (widget.specificReminderTime == null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Wrap(
                spacing: 8,
                children: DaySection.values.map((section) {
                  return ChoiceChip(
                    label: Text(section.label),
                    selected: section == widget.reminderTime,
                    onSelected: (_) => widget.onReminderTimeChanged(section),
                  );
                }).toList(),
              ),
            ),
          ],

          // Option 2: Select specific time
          Row(
            children: [
              Radio<bool>(
                value: false,
                groupValue: widget.specificReminderTime == null,
                onChanged: (value) {
                  if (value == false) {
                    widget.onReminderTimeChanged(null);
                    widget.onSpecificTimeChanged(TimeOfDay.now());
                  }
                },
              ),
              const Text('Specific time'),
              const SizedBox(width: 16),
              if (widget.specificReminderTime != null)
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text(
                    '${widget.specificReminderTime!.hour.toString().padLeft(2, '0')}:${widget.specificReminderTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
