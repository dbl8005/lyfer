import 'package:flutter/material.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/empty_states/empty_section_message.dart';
import 'package:lyfer/features/habits/presentation/widgets/lists/habits_list.dart';
import 'package:lyfer/features/habits/presentation/widgets/display/section_header.dart';

class HabitSection extends StatelessWidget {
  final DaySection section;
  final List<HabitModel> habits;
  final bool isCurrentSection;
  final DateTime selectedDate;

  const HabitSection({
    super.key,
    required this.section,
    required this.habits,
    required this.selectedDate,
    this.isCurrentSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          section: section,
          isCurrentSection: isCurrentSection,
        ),
        const SizedBox(height: 12),
        habits.isEmpty
            ? EmptySectionMessage(section: section)
            : HabitsList(habits: habits, selectedDate: selectedDate),
      ],
    );
  }
}
