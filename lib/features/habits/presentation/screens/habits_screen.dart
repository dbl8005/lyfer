import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/habit_tile.dart';
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
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
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

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHabitSection(
                  context: context,
                  section: DaySection.morning,
                  habits: morningHabits,
                ),
                const SizedBox(height: 24),
                _buildHabitSection(
                  context: context,
                  section: DaySection.noon,
                  habits: noonHabits,
                ),
                const SizedBox(height: 24),
                _buildHabitSection(
                  context: context,
                  section: DaySection.evening,
                  habits: eveningHabits,
                ),
                const SizedBox(height: 24),
                _buildHabitSection(
                  context: context,
                  section: DaySection.allDay,
                  habits: alldayHabits,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_task,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first habit by tapping the + button',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitSection({
    required BuildContext context,
    required DaySection section,
    required List<HabitModel> habits,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, section),
        const SizedBox(height: 12),
        habits.isEmpty
            ? _buildEmptySectionMessage(section)
            : _buildHabitsList(habits),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, DaySection section) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          LineIcon(
            section.icon,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            section.displayText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySectionMessage(DaySection section) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Text(
          'No ${section.displayText.toLowerCase()} habits yet',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsList(List<HabitModel> habits) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: habits.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: HabitTile(habit: habit),
        );
      },
    );
  }
}
