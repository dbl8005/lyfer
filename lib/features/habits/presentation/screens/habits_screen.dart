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
  // Add a scroll controller
  final ScrollController _scrollController = ScrollController();
  // Current section indicator
  late DaySection _currentSection;
  // Map to store section positions
  final Map<DaySection, GlobalKey> _sectionKeys = {
    DaySection.morning: GlobalKey(),
    DaySection.afternoon: GlobalKey(),
    DaySection.evening: GlobalKey(),
    DaySection.night: GlobalKey(),
    DaySection.allDay: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _currentSection = _getCurrentDaySection();

    // Schedule scroll after first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentSection();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentSection() {
    final currentKey = _sectionKeys[_currentSection];
    if (currentKey?.currentContext != null) {
      // Get the render box from the section key
      final RenderBox renderBox =
          currentKey!.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);

      // Scroll to the position with a small offset for better visibility
      _scrollController.animateTo(
        position.dy - 80, // Offset to show a bit above the section
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Get sections in chronological order (always the same)
  List<DaySection> _getSectionOrder() {
    return [
      DaySection.morning,
      DaySection.afternoon,
      DaySection.evening,
      DaySection.night,
      DaySection.allDay,
    ];
  }

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

        // Call it in your build method before returning the widget
        if (snapshot.hasData) {
          _checkHabitIcons(snapshot.data!);
        }

        // Group habits by section
        final habitsBySection = _groupHabitsBySection(habits);

        // Get sections in chronological order
        final sectionOrder = _getSectionOrder();

        return SingleChildScrollView(
          controller: _scrollController, // Add the scroll controller
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Build sections in chronological order
                for (int i = 0; i < sectionOrder.length; i++)
                  Column(
                    key: _sectionKeys[sectionOrder[i]], // Add section key
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHabitSection(
                        context: context,
                        section: sectionOrder[i],
                        habits: habitsBySection[sectionOrder[i]] ?? [],
                        isCurrentSection: sectionOrder[i] == _currentSection,
                      ),
                      Divider(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                      ),
                    ],
                  ),
                const SizedBox(height: 130), // Bottom padding
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
      return DaySection.afternoon;
    } else if (hour >= 17 && hour < 21) {
      return DaySection.evening;
    } else {
      return DaySection.night;
    }
  }

  // Group habits by section
  Map<DaySection, List<HabitModel>> _groupHabitsBySection(
      List<HabitModel> habits) {
    return {
      DaySection.morning: habits
          .where((habit) => habit.preferredTime == DaySection.morning)
          .toList(),
      DaySection.afternoon: habits // Change from noon to afternoon
          .where((habit) => habit.preferredTime == DaySection.afternoon)
          .toList(),
      DaySection.evening: habits
          .where((habit) => habit.preferredTime == DaySection.evening)
          .toList(),
      DaySection.night: habits
          .where((habit) => habit.preferredTime == DaySection.night)
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
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
            section.label,
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
    return Column(
      children: [
        Container(
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
              'No ${section.label.toLowerCase()} habits yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildHabitsList(List<HabitModel> habits) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: habits.length,
      padding: EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 0,
      ),
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: HabitTile(habit: habit),
        );
      },
    );
  }

  // Add this to your HabitsScreen build method for debugging
  void _checkHabitIcons(List<HabitModel> habits) {
    for (final habit in habits) {
      try {
        final icon = habit.category.icon;
        print('Habit ${habit.name} has valid icon: $icon');
      } catch (e) {
        print('ERROR: Habit ${habit.name} has invalid icon: $e');
      }
    }
  }
}
