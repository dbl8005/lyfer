import 'package:lyfer/features/habits/models/habit_model.dart';

class StreakCalculator {
  /// Calculate the current streak for a habit
  static int calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    // Sort dates in descending order (newest first)
    final sortedDates = [...completedDates]..sort((a, b) => b.compareTo(a));

    // Get today and yesterday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if there's a completion today or yesterday
    bool hasTodayOrYesterday = false;
    for (var date in sortedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final difference = today.difference(normalizedDate).inDays;
      if (difference == 0 || difference == 1) {
        hasTodayOrYesterday = true;
        break;
      }
    }

    // If we don't have today or yesterday marked as complete, streak is 0
    if (!hasTodayOrYesterday) return 0;

    // Now count the streak
    int streak = 0;
    DateTime? lastDate;

    // Convert all dates to date-only (no time) and remove duplicates
    final uniqueDates = completedDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    for (var date in uniqueDates) {
      if (lastDate == null) {
        // First date in streak
        streak = 1;
        lastDate = date;
        continue;
      }

      // Calculate difference between current date and last date
      final difference = lastDate.difference(date).inDays;

      // If difference is 1 day, continue the streak
      if (difference == 1) {
        streak++;
        lastDate = date;
      } else {
        // Break in streak
        break;
      }
    }

    return streak;
  }
}
