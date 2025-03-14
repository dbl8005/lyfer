import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/config/constants/habit_constants.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/features/habits/presentation/widgets/navigation/day_navigator.dart';
import 'package:lyfer/features/habits/presentation/widgets/lists/habit_section.dart';
import 'package:lyfer/features/habits/providers/habits_provider.dart';

/// Displays the main content of the habits screen including
/// day navigation and habit sections grouped by time of day
class HabitsContent extends ConsumerWidget {
  final ScrollController scrollController;
  final Map<DaySection, GlobalKey> sectionKeys;

  const HabitsContent({
    super.key,
    required this.scrollController,
    required this.sectionKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final currentSection = ref.watch(currentSectionProvider);
    final habitsBySection = ref.watch(groupedHabitsProvider);

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DayNavigator(
              selectedDate: selectedDate,
              today: today,
              onPreviousDayPressed: () => ref
                  .read(selectedDateProvider.notifier)
                  .update((state) => state.subtract(const Duration(days: 1))),
              onNextDayPressed: () {
                final isToday = selectedDate.year == today.year &&
                    selectedDate.month == today.month &&
                    selectedDate.day == today.day;

                if (!isToday) {
                  ref
                      .read(selectedDateProvider.notifier)
                      .update((state) => state.add(const Duration(days: 1)));
                }
              },
              onTodayPressed: () => ref
                  .read(selectedDateProvider.notifier)
                  .update((_) => DateTime.now()),
            ),

            // Build sections in chronological order
            for (final section in HabitsConstants.sectionOrder)
              Column(
                key: sectionKeys[section],
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HabitSection(
                    section: section,
                    habits: habitsBySection[section] ?? [],
                    selectedDate: selectedDate,
                    isCurrentSection: section == currentSection,
                  ),
                  Divider(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ],
              ),

            const SizedBox(height: HabitsConstants.bottomPadding),
          ],
        ),
      ),
    );
  }
}
