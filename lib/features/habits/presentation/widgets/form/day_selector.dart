import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final Set<int> selectedDays;
  final Function(Set<int>) onDaysSelected;
  final bool dailyHabit;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onDaysSelected,
    this.dailyHabit = false,
  });

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late Set<int> _selectedDays;
  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = {...widget.selectedDays};
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      // For daily habits, we always need at least one day selected
      if (widget.dailyHabit &&
          _selectedDays.length == 1 &&
          _selectedDays.contains(dayIndex)) {
        return;
      }

      if (_selectedDays.contains(dayIndex)) {
        _selectedDays.remove(dayIndex);
      } else {
        _selectedDays.add(dayIndex);
      }
      widget.onDaysSelected(_selectedDays);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            final isSelected = _selectedDays.contains(index);
            return FilterChip(
              label: Text(_daysOfWeek[index]),
              selected: isSelected,
              onSelected: (_) => _toggleDay(index),
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
}
