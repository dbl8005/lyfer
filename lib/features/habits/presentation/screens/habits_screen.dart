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

        // Determine current day section based on time of day
        final currentDaySection = _getCurrentDaySection();

        // Create sections list in order based on current time
        final sectionOrder = _getSectionOrder(currentDaySection);

        // Group habits by section
        final habitsBySection = _groupHabitsBySection(habits);

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Build sections in the determined order
                for (int i = 0; i < sectionOrder.length; i++)
                  Column(
                    children: [
                      _buildHabitSection(
                        context: context,
                        section: sectionOrder[i],
                        habits: habitsBySection[sectionOrder[i]] ?? [],
                        isCurrentSection: sectionOrder[i] == currentDaySection,
                      ),
                      if (i < sectionOrder.length - 1)
                        const SizedBox(height: 24),
                    ],
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Get current day section based on time
  DaySection _getCurrentDaySection() {
    final now = TimeOfDay.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return DaySection.morning;
    } else if (hour >= 12 && hour < 17) {
      return DaySection.noon;
    } else {
      return DaySection.evening;
    }
  }

  // Get ordered sections with current section first and all day last
  List<DaySection> _getSectionOrder(DaySection currentSection) {
    List<DaySection> sections = [
      DaySection.morning,
      DaySection.noon,
      DaySection.evening,
    ];

    if (currentSection == DaySection.morning) {
      sections = [
        DaySection.morning,
        DaySection.noon,
        DaySection.evening,
        DaySection.allDay,
      ];
    }
    if (currentSection == DaySection.noon) {
      sections = [
        DaySection.noon,
        DaySection.evening,
        DaySection.allDay,
        DaySection.morning,
      ];
    }
    if (currentSection == DaySection.evening) {
      sections = [
        DaySection.evening,
        DaySection.allDay,
        DaySection.morning,
        DaySection.noon,
      ];
    }

    return sections;
  }

  // Group habits by section
  Map<DaySection, List<HabitModel>> _groupHabitsBySection(
      List<HabitModel> habits) {
    return {
      DaySection.morning: habits
          .where((habit) => habit.preferredTime == DaySection.morning)
          .toList(),
      DaySection.noon: habits
          .where((habit) => habit.preferredTime == DaySection.noon)
          .toList(),
      DaySection.evening: habits
          .where((habit) => habit.preferredTime == DaySection.evening)
          .toList(),
      DaySection.allDay: habits
          .where((habit) => habit.preferredTime == DaySection.allDay)
          .toList(),
    };
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
    bool isCurrentSection = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, section, isCurrentSection),
        const SizedBox(height: 12),
        habits.isEmpty
            ? _buildEmptySectionMessage(section)
            : _buildHabitsList(habits),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, DaySection section, bool isCurrentSection) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentSection
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          LineIcon(
            section.icon,
            size: 28,
            color: isCurrentSection
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
          if (isCurrentSection) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Now',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
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
