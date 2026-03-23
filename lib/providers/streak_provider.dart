import 'package:flutter/foundation.dart';
import '../data/models/streak.dart';
import '../data/models/badge.dart';
import '../data/database/streak_dao.dart';
import '../data/database/badge_dao.dart';
import '../data/database/habit_dao.dart';
import '../core/utils/streak_calculator.dart';

/// Manages streak state for all habits.
/// Also triggers badge checking whenever a streak is updated.
class StreakProvider extends ChangeNotifier {
  final StreakDao _streakDao = StreakDao();
  final BadgeDao _badgeDao = BadgeDao();
  final HabitDao _habitDao = HabitDao();

  // Map of habitId → Streak
  Map<String, Streak> _streaks = {};
  List<Badge> _newlyEarnedBadges = [];
  bool _isLoading = false;

  // Getters
  Map<String, Streak> get streaks => Map.unmodifiable(_streaks);
  List<Badge> get newlyEarnedBadges => List.unmodifiable(_newlyEarnedBadges);
  bool get isLoading => _isLoading;

  /// Returns the streak for a specific habit
  Streak? streakFor(String habitId) => _streaks[habitId];

  /// Returns the highest current streak across all habits
  int get topCurrentStreak {
    if (_streaks.isEmpty) return 0;
    return _streaks.values
        .map((s) => s.currentStreak)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Clears the new badge notification queue (call after showing alerts)
  void clearNewBadges() {
    _newlyEarnedBadges = [];
    notifyListeners();
  }

  // Load all streaks

  Future<void> loadStreaks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allStreaks = await _streakDao.getAllStreaks();
      _streaks = {for (final s in allStreaks) s.habitId: s};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process a habit completion

  /// Called after a habit is marked complete.
  /// Updates streak, handles shield logic, and checks for new badges.
  Future<void> processCompletion(String habitId) async {
    Streak? streak = _streaks[habitId];

    // Create streak record if it doesn't exist yet
    if (streak == null) {
      streak = await _streakDao.createDefaultStreak(habitId);
      _streaks[habitId] = streak;
    }

    final today = DateTime.now().toIso8601String();

    // Determine if streak should be extended or reset based on last completion
    if (streak.lastCompleted != null) {
      final last = DateTime.parse(streak.lastCompleted!);
      final diff = DateTime.now().difference(last).inDays;

      if (diff == 1) {
        // Consecutive day — extend streak
        await _streakDao.incrementStreak(habitId, today);
        streak.currentStreak += 1;
        if (streak.currentStreak > streak.longestStreak) {
          streak.longestStreak = streak.currentStreak;
        }
      } else if (diff == 2) {
        // One day missed — try shield activation
        final shielded = await _streakDao.activateShield(habitId);
        if (shielded) {
          // Shield activated — streak preserved
          await _streakDao.incrementStreak(habitId, today);
          streak.currentStreak += 1;
        } else {
          // No shields — reset and start fresh
          await _streakDao.resetStreak(habitId);
          streak.currentStreak = 1;
        }
        streak.lastCompleted = today;
      } else if (diff > 2) {
        // Too many days missed — reset streak
        await _streakDao.resetStreak(habitId);
        streak.currentStreak = 1;
        streak.lastCompleted = today;
      }
      // diff == 0 means already completed today, no change
    } else {
      // First ever completion
      streak.currentStreak = 1;
      streak.lastCompleted = today;
      streak.longestStreak = 1;
      await _streakDao.updateStreak(streak);
    }

    _streaks[habitId] = streak;

    // Check for newly unlocked badges
    await _checkBadges(streak.currentStreak, habitId);
    notifyListeners();
  }

  // Private helpers

  Future<void> _checkBadges(int currentStreak, String habitId) async {
    // Check streak badges
    final streakBadges = await _badgeDao.checkStreakBadges(currentStreak);

    // Check level badges
    final habit = await _habitDao.getHabitById(habitId);
    List<Badge> levelBadges = [];
    if (habit != null) {
      levelBadges = await _badgeDao.checkLevelBadges(habit.level);
    }

    // Check total completion count badges
    final logs = await _habitDao.getLogsForHabit(habitId);
    final completionBadges = await _badgeDao.checkCompletionBadges(logs.length);

    // Queue up any newly earned badges for notification
    _newlyEarnedBadges = [...streakBadges, ...levelBadges, ...completionBadges];
  }

 //initiate streak for habit
 Future<void> initStreakForHabit(String habitId) async {
   final streak = await _streakDao.createDefaultStreak(habitId);
   _streaks[habitId] = streak;
   notifyListeners();
 }
}