import 'package:flutter/material.dart';
import 'package:lyfer/core/constants/app_constants.dart';

class TaskUtils {
  /// Returns appropriate color based on task due date
  static Color getDueDateColor(DateTime dueDate, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return AppTaskColors.overdue; // Overdue
    } else if (difference == 0) {
      return AppTaskColors.dueToday; // Due today
    } else if (difference <= 2) {
      return AppTaskColors.dueSoon; // Due soon
    }
    return Theme.of(context).colorScheme.onSurfaceVariant; // Normal
  }

  /// Simpler version without context dependency for reuse in dashboard
  static Color getSimpleDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return AppTaskColors.overdue; // Overdue
    } else if (difference == 0) {
      return AppTaskColors.dueToday; // Due today
    } else if (difference <= 2) {
      return AppTaskColors.dueSoon; // Due soon
    }
    return AppTaskColors.normal; // Normal
  }
}
