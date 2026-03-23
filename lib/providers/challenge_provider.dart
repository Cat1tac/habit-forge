import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/challenge.dart';
import '../data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ChallengeProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Challenge> _challenges = [];
  bool _isLoading = false;

  // Getters
  List<Challenge> get challenges => List.unmodifiable(_challenges);
  List<Challenge> get activeChallenges =>
      _challenges.where((c) => !c.isCompleted && !c.isExpired).toList();
  List<Challenge> get completedChallenges =>
      _challenges.where((c) => c.isCompleted).toList();
  bool get isLoading => _isLoading;

  // Load challenges from database
  Future<void> loadChallenges() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      final maps = await db.query('challenges', orderBy: 'start_date DESC');
      _challenges = maps.map((m) => Challenge.fromMap(m)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adaptive challenge generation

  Future<void> generateAdaptiveChallenges({
    required int currentStreak,
    required int weeklyCompletionRate,  // 0–100
    required int totalXp,
  }) async {
    final newChallenges = <Challenge>[];

    // --- Streak challenge: 20% harder than current best ---
    final streakTarget = (currentStreak * 1.2).round().clamp(3, 90);
    newChallenges.add(Challenge(
      title: 'Streak Crusher',
      description: 'Maintain a $streakTarget-day streak',
      targetValue: streakTarget,
      challengeType: 'streak',
      difficulty: _difficultyFor(streakTarget, 7, 30, 60),
      rewardXp: _rewardFor(streakTarget, 7, 30, 60),
    ));

    // --- Completion challenge based on weekly rate ---
    final completionTarget = weeklyCompletionRate < 60
        ? 5   // Easy: just 5 completions this week
        : weeklyCompletionRate < 80
            ? 14  // Medium: 14 completions
            : 21; // Hard: 3 a day for a week
    newChallenges.add(Challenge(
      title: 'Completion Blitz',
      description: 'Log $completionTarget habit completions this week',
      targetValue: completionTarget,
      challengeType: 'completion',
      difficulty: _difficultyFor(completionTarget, 5, 14, 21),
      rewardXp: _rewardFor(completionTarget, 5, 14, 21),
    ));

    // --- XP challenge ---
    final xpTarget = (totalXp * 0.1).round().clamp(50, 500);
    newChallenges.add(Challenge(
      title: 'XP Grind',
      description: 'Earn $xpTarget XP this week',
      targetValue: xpTarget,
      challengeType: 'xp',
      difficulty: _difficultyFor(xpTarget, 50, 150, 300),
      rewardXp: (xpTarget * 0.3).round(),
    ));

    // Insert into database
    final db = await _dbHelper.database;
    for (final c in newChallenges) {
      await db.insert('challenges', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    _challenges.insertAll(0, newChallenges);
    notifyListeners();
  }

  // Update challenge progress

  /// Increments the progress of all active challenges that match the type.
  Future<void> incrementProgress(String challengeType, {int amount = 1}) async {
    final db = await _dbHelper.database;
    final matching = activeChallenges
        .where((c) => c.challengeType == challengeType)
        .toList();

    for (final c in matching) {
      c.currentValue += amount;
      // Check if the challenge is now complete
      if (c.currentValue >= c.targetValue && !c.isCompleted) {
        c.isCompleted = true;
      }
      await db.update('challenges', c.toMap(),
          where: 'id = ?', whereArgs: [c.id]);
    }

    notifyListeners();
  }

  // Private helpers

  String _difficultyFor(int value, int easy, int medium, int hard) {
    if (value <= easy) return 'easy';
    if (value <= medium) return 'medium';
    return 'hard';
  }

  int _rewardFor(int value, int easy, int medium, int hard) {
    if (value <= easy) return 25;
    if (value <= medium) return 50;
    return 100;
  }
}