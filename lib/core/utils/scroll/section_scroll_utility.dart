import 'package:flutter/material.dart';
import 'package:lyfer/core/config/constants/habit_constants.dart';
import 'package:lyfer/features/habits/domain/enums/habit_enums.dart';

/// Utility class that handles scrolling to specific sections in a scrollable view
class SectionScrollUtility {
  /// Scrolls to the specified section using the provided scroll controller and section keys
  static void scrollToSection({
    required ScrollController scrollController,
    required Map<DaySection, GlobalKey> sectionKeys,
    required DaySection targetSection,
  }) {
    final targetKey = sectionKeys[targetSection];

    if (targetKey?.currentContext != null) {
      final RenderBox renderBox =
          targetKey!.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);

      scrollController.animateTo(
        position.dy - HabitsConstants.sectionScrollOffset,
        duration: HabitsConstants.scrollAnimationDuration,
        curve: HabitsConstants.scrollAnimationCurve,
      );
    }
  }
}
