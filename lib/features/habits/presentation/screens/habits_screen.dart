import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/config/constants/habit_constants.dart';
import 'package:lyfer/core/config/constants/ui_constants.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/scroll/section_scroll_utility.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';
import 'package:lyfer/features/habits/presentation/widgets/habits_content.dart';
import 'package:lyfer/features/habits/presentation/widgets/state_handlers/habit_state_handler.dart';

/// The main habits screen that displays habits organized by time of day
/// with navigation controls for different dates
class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<DaySection, GlobalKey> _sectionKeys = {
    for (var section in HabitsConstants.sectionOrder) section: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
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

  /// Scrolls to the current time section for better user experience
  void _scrollToCurrentSection() {
    final currentSection = ref.read(currentSectionProvider);

    SectionScrollUtility.scrollToSection(
      scrollController: _scrollController,
      sectionKeys: _sectionKeys,
      targetSection: currentSection,
    );
  }

  /// Navigates to the habit creation screen
  void _navigateToCreateHabit() {
    Navigator.of(context).pushNamed(AppRouterConsts.newHabit);
  }

  @override
  Widget build(BuildContext context) {
    final habitStream = ref.watch(habitsRepositoryProvider).watchHabits();

    return Semantics(
      label: UIConstants.habitsScreenLabel,
      child: HabitStateHandler(
        habitsStream: habitStream,
        onCreateHabit: _navigateToCreateHabit,
        onRetry: () => ref.refresh(habitsRepositoryProvider),
        dataBuilder: (habits) => HabitsContent(
          scrollController: _scrollController,
          sectionKeys: _sectionKeys,
        ),
      ),
    );
  }
}
