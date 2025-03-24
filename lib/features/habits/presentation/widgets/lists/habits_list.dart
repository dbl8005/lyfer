import 'package:flutter/material.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/display/habit_tile.dart';

class HabitsList extends StatelessWidget {
  final List<HabitModel> habits;
  final DateTime selectedDate;

  const HabitsList({
    super.key,
    required this.habits,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: habits.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: HabitTile(
            habit: habit,
            selectedDate: selectedDate,
          ),
        );
      },
    );
  }
}
