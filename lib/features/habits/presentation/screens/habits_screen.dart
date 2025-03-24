import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/config/constants/habit_constants.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/widgets/error_display.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';
import 'package:lyfer/features/habits/presentation/widgets/empty_states/empty_habits_view.dart';
import 'package:lyfer/features/habits/presentation/widgets/habits_content.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';

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
    final currentKey = _sectionKeys[currentSection];

    if (currentKey?.currentContext != null) {
      final RenderBox renderBox =
          currentKey!.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);

      _scrollController.animateTo(
        position.dy - HabitsConstants.sectionScrollOffset,
        duration: HabitsConstants.scrollAnimationDuration,
        curve: HabitsConstants.scrollAnimationCurve,
      );
    }
  }

  /// Navigates to the habit creation screen
  void _navigateToCreateHabit() {
    Navigator.of(context).pushNamed(AppRouterConsts.newHabit);
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsyncValue = ref.watch(habitsStreamProvider);

    return Semantics(
      label: 'Habits screen',
      child: habitsAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Loading habits',
          ),
        ),
        error: (error, stack) => ErrorDisplay(
          errorMessage: 'Failed to load habits: $error',
          onRetry: () => ref.refresh(habitsStreamProvider),
        ),
        data: (habits) {
          if (habits.isEmpty) {
            return EmptyHabitsView(onCreateHabit: _navigateToCreateHabit);
          }

          return HabitsContent(
            scrollController: _scrollController,
            sectionKeys: _sectionKeys,
          );
        },
      ),
    );
  }
}
