import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    final habitsStream = ref.watch(habitServiceProvider).getHabits();

    return StreamBuilder<List<HabitModel>>(
      stream: habitsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No habits yet. Create your first habit!'),
          );
        }

        final habits = snapshot.data!;
        final morningHabits = habits
            .where((habit) => habit.preferredTime == DaySection.morning)
            .toList();
        final noonHabits = habits
            .where((habit) => habit.preferredTime == DaySection.noon)
            .toList();
        final eveningHabits = habits
            .where((habit) => habit.preferredTime == DaySection.evening)
            .toList();
        final alldayHabits = habits
            .where((habit) => habit.preferredTime == DaySection.allDay)
            .toList();
        return Column(
          children: [
            Row(children: [
              LineIcon(DaySection.morning.icon, size: 36),
              const SizedBox(width: 8),
              Text(DaySection.morning.displayText,
                  style: const TextStyle(fontSize: 34)),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: morningHabits.length,
                itemBuilder: (context, index) {
                  final habit = morningHabits[index];
                  return HabitTile(habit: habit);
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              LineIcon(DaySection.noon.icon, size: 36),
              const SizedBox(width: 8),
              Text(DaySection.noon.displayText,
                  style: const TextStyle(fontSize: 34)),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: noonHabits.length,
                itemBuilder: (context, index) {
                  final habit = noonHabits[index];
                  return HabitTile(habit: habit);
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              LineIcon(DaySection.evening.icon, size: 36),
              const SizedBox(width: 8),
              Text(DaySection.evening.displayText,
                  style: const TextStyle(fontSize: 34)),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: eveningHabits.length,
                itemBuilder: (context, index) {
                  final habit = eveningHabits[index];
                  return HabitTile(habit: habit);
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              LineIcon(DaySection.allDay.icon, size: 36),
              const SizedBox(width: 8),
              Text(DaySection.allDay.displayText,
                  style: const TextStyle(fontSize: 34)),
            ]),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
  });

  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: LineIcon(
          HabitIcon.values.firstWhere((e) => e.name == habit.icon).icon),
      title: Text(habit.name),
      subtitle: Text(habit.description),
      trailing: Text('${habit.streakCount} days'),
    );
  }
}
