import '../../data/models/habit_log.dart';
import 'date_utils.dart';

class ScoreCalculator {
  ScoreCalculator._(); // Prevent instantiation

  // Weekly Score

  /// Calculates the aggregate score for the current week.
  /// [logs] — all habit logs for a given habit.
  /// Returns 0–100 percentage of max possible score.
  static int weeklyScore(List<HabitLog> logs) {
    final weekDays = AppDateUtils.currentWeekDays();
    final logsThisWeek = logs.where((log) {
      final logDate = DateTime.parse(log.completedDate);
      return weekDays.any((d) => AppDateUtils.isSameDay(d, logDate));
    }).toList();

    if (logsThisWeek.isEmpty) return 0;

    final totalScore = logsThisWeek.fold(0, (sum, log) => sum + log.score);
    // Max possible: 7 days × 150 max score per day
    const maxPossible = 7 * 150;
    return ((totalScore / maxPossible) * 100).clamp(0, 100).round();
  }

  // Completion Rate

  /// Returns percentage of days in the last [days] days that were completed.
  /// [completedDates] — set of dates when habit was done.
  static int completionRate({
    required Set<DateTime> completedDates,
    int days = 30,
  }) {
    if (days == 0) return 0;
    final now = DateTime.now();
    int completed = 0;

    for (int i = 0; i < days; i++) {
      final day = AppDateUtils.toDateOnly(
        now.subtract(Duration(days: i)),
      );
      if (completedDates.contains(day)) completed++;
    }

    return ((completed / days) * 100).round();
  }

  // XP per completion (also used in HabitProvider)

  /// Calculates XP to award for a single completion.
  /// More XP is awarded for longer streaks and higher habit levels.
  static int xpForCompletion({
    required int currentStreak,
    required int habitLevel,
  }) {
    // Base XP scales with level
    final base = 10 + (habitLevel - 1) * 2;
    // Streak multiplier: +10% per 7-day block, max +50%
    final streakMultiplier = 1.0 + ((currentStreak ~/ 7) * 0.1).clamp(0.0, 0.5);
    return (base * streakMultiplier).round();
  }

  // League rank calculation

  /// Returns a rank title based on total XP.
  static String rankTitle(int totalXp) {
    if (totalXp < 100) return 'Rookie';
    if (totalXp < 300) return 'Apprentice';
    if (totalXp < 600) return 'Warrior';
    if (totalXp < 1000) return 'Champion';
    if (totalXp < 2000) return 'Legend';
    return 'Grand Master';
  }

  /// Returns an emoji for the current rank
  static String rankEmoji(int totalXp) {
    if (totalXp < 100) return '🌱';
    if (totalXp < 300) return '⚔️';
    if (totalXp < 600) return '🛡️';
    if (totalXp < 1000) return '🏆';
    if (totalXp < 2000) return '⭐';
    return '👑';
  }

  // Badge progress

  /// Returns progress (0.0–1.0) toward a badge's condition value.
  static double badgeProgress({
    required int currentValue,
    required int targetValue,
  }) {
    if (targetValue <= 0) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }
}