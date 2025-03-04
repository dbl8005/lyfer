import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
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
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return Card(
              child: ListTile(
                leading: LineIcon(
                  // ! Shows a different icon
                  HabitIcon.getIconData(habit.icon),
                  color: habit.color ?? Theme.of(context).primaryColor,
                  size: 28,
                ),
                title: Text(
                  habit.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(habit.description),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // TODO: Add habit options menu
                  },
                ),
                onTap: () {
                  // TODO: Navigate to habit details
                },
              ),
            );
          },
        );
      },
    );
  }
}
