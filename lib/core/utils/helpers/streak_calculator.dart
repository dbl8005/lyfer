import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';

class StreakCalculator {
  /// Calculate the current streak for a habit based on its frequency
  static int calculateStreak(
      List<DateTime> completedDates, Frequency frequency, int timesPerPeriod) {
    if (completedDates.isEmpty) return 0;

    // Sort dates in descending order (newest first)
    final sortedDates = [...completedDates]..sort((a, b) => b.compareTo(a));

    switch (frequency) {
      case Frequency.daily:
        return _calculateDailyStreak(sortedDates);
      case Frequency.weekly:
        return _calculateWeeklyStreak(sortedDates, timesPerPeriod);
      case Frequency.monthly:
        return _calculateMonthlyStreak(sortedDates, timesPerPeriod);
      case Frequency.custom:
        // For custom frequency, we'll use the daily streak calculation for now
        return _calculateDailyStreak(sortedDates);
    }
  }

  // Calculate streak for daily habits
  static int _calculateDailyStreak(List<DateTime> sortedDates) {
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

    // Convert all dates to date-only (no time) and remove duplicates
    final uniqueDates = sortedDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    // Now count the streak
    int streak = 0;
    DateTime? lastDate;

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

  // Calculate streak for weekly habits
  static int _calculateWeeklyStreak(
      List<DateTime> sortedDates, int timesPerPeriod) {
    final now = DateTime.now();

    // Group dates by week
    Map<int, List<DateTime>> completionsByWeek = {};

    for (var date in sortedDates) {
      // Get week number (roughly the week of the year)
      int weekOfYear = _getWeekNumber(date);
      int yearWeekKey =
          date.year * 100 + weekOfYear; // Unique key for year+week

      if (!completionsByWeek.containsKey(yearWeekKey)) {
        completionsByWeek[yearWeekKey] = [];
      }
      completionsByWeek[yearWeekKey]!.add(date);
    }

    // Convert to list of week keys in descending order
    List<int> weekKeys = completionsByWeek.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Current week info
    int currentWeekKey = now.year * 100 + _getWeekNumber(now);
    bool isCurrentWeekComplete =
        (completionsByWeek[currentWeekKey]?.length ?? 0) >= timesPerPeriod;
    bool hasCurrentWeekCompletions =
        completionsByWeek.containsKey(currentWeekKey) &&
            completionsByWeek[currentWeekKey]!.isNotEmpty;

    // Last week info
    DateTime lastWeek = now.subtract(const Duration(days: 7));
    int lastWeekKey = lastWeek.year * 100 + _getWeekNumber(lastWeek);
    bool isLastWeekComplete =
        (completionsByWeek[lastWeekKey]?.length ?? 0) >= timesPerPeriod;

    // If current week has no completions and last week is not complete, streak is 0
    if (!hasCurrentWeekCompletions && !isLastWeekComplete) {
      return 0;
    }

    // Count consecutive weeks with enough completions
    int streak = 0;
    int? expectedWeekKey;

    // Start with the most recent completed week
    // If current week has completions, start with current week
    // Otherwise, start with the last completed week
    int startingWeekIndex = 0;

    // If current week has completions but isn't complete yet,
    // we still count it in the streak (as 1)
    if (hasCurrentWeekCompletions) {
      streak = 1;

      // The next expected week is last week
      expectedWeekKey = lastWeekKey;

      // Skip current week in our iteration
      if (weekKeys.isNotEmpty && weekKeys[0] == currentWeekKey) {
        startingWeekIndex = 1;
      }
    }

    // Now check previous weeks (starting after current week if needed)
    for (int i = startingWeekIndex; i < weekKeys.length; i++) {
      int weekKey = weekKeys[i];

      // First iteration when we don't have a streak yet
      if (streak == 0) {
        if (completionsByWeek[weekKey]!.length >= timesPerPeriod) {
          streak = 1;

          // Calculate the expected previous week
          int weekNum = weekKey % 100;
          int year = weekKey ~/ 100;

          if (weekNum == 1) {
            // If it's the first week, the previous week is the last week of previous year
            expectedWeekKey =
                (year - 1) * 100 + 52; // Assuming 52 weeks per year
          } else {
            expectedWeekKey = year * 100 + (weekNum - 1);
          }
        }
        continue;
      }

      // Check if this is the expected previous week
      if (weekKey == expectedWeekKey &&
          completionsByWeek[weekKey]!.length >= timesPerPeriod) {
        streak++;

        // Calculate next expected week
        int weekNum = weekKey % 100;
        int year = weekKey ~/ 100;

        if (weekNum == 1) {
          expectedWeekKey = (year - 1) * 100 + 52;
        } else {
          expectedWeekKey = year * 100 + (weekNum - 1);
        }
      } else {
        // Break in streak
        break;
      }
    }

    return streak;
  }

  // Calculate streak for monthly habits
  static int _calculateMonthlyStreak(
      List<DateTime> sortedDates, int timesPerPeriod) {
    final now = DateTime.now();

    // Group dates by month
    Map<int, List<DateTime>> completionsByMonth = {};

    for (var date in sortedDates) {
      int monthKey =
          date.year * 12 + date.month - 1; // Unique key for year+month

      if (!completionsByMonth.containsKey(monthKey)) {
        completionsByMonth[monthKey] = [];
      }
      completionsByMonth[monthKey]!.add(date);
    }

    // Convert to list of month keys in descending order
    List<int> monthKeys = completionsByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Current month info
    int currentMonthKey = now.year * 12 + now.month - 1;
    bool isCurrentMonthComplete =
        (completionsByMonth[currentMonthKey]?.length ?? 0) >= timesPerPeriod;
    bool hasCurrentMonthCompletions =
        completionsByMonth.containsKey(currentMonthKey) &&
            completionsByMonth[currentMonthKey]!.isNotEmpty;

    // Last month info
    int lastMonthKey = currentMonthKey - 1;
    bool isLastMonthComplete =
        (completionsByMonth[lastMonthKey]?.length ?? 0) >= timesPerPeriod;

    // If current month has no completions and last month is not complete, streak is 0
    if (!hasCurrentMonthCompletions && !isLastMonthComplete) {
      return 0;
    }

    // Count consecutive months with enough completions
    int streak = 0;
    int? expectedMonthKey;

    // Start with the most recent completed month
    int startingMonthIndex = 0;

    // If current month has completions but isn't complete yet,
    // we still count it in the streak (as 1)
    if (hasCurrentMonthCompletions) {
      streak = 1;

      // The next expected month is last month
      expectedMonthKey = lastMonthKey;

      // Skip current month in our iteration
      if (monthKeys.isNotEmpty && monthKeys[0] == currentMonthKey) {
        startingMonthIndex = 1;
      }
    }

    // Now check previous months
    for (int i = startingMonthIndex; i < monthKeys.length; i++) {
      int monthKey = monthKeys[i];

      // First iteration when we don't have a streak yet
      if (streak == 0) {
        if (completionsByMonth[monthKey]!.length >= timesPerPeriod) {
          streak = 1;
          expectedMonthKey = monthKey - 1; // Previous month
        }
        continue;
      }

      // Check if this is the expected previous month
      if (monthKey == expectedMonthKey &&
          completionsByMonth[monthKey]!.length >= timesPerPeriod) {
        streak++;
        expectedMonthKey = monthKey - 1;
      } else {
        // Break in streak
        break;
      }
    }

    return streak;
  }

  // Helper method to get ISO week number
  static int _getWeekNumber(DateTime date) {
    int dayOfYear =
        int.parse('${date.difference(DateTime(date.year, 1, 1)).inDays + 1}');
    int weekOfYear = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekOfYear;
  }
}
