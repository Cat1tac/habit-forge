import 'package:sqflite/sqflite.dart';
import '../models/badge.dart';
import 'database_helper.dart';

/// Data Access Object for Badge CRUD operations.
class BadgeDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // READ

  /// Returns all badge definitions (earned and unearned)
  Future<List<Badge>> getAllBadges() async {
    final db = await _dbHelper.database;
    final maps = await db.query('badges', orderBy: 'is_earned DESC');
    return maps.map((m) => Badge.fromMap(m)).toList();
  }

  /// Returns only earned badges
  Future<List<Badge>> getEarnedBadges() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'badges',
      where: 'is_earned = ?',
      whereArgs: [1],
      orderBy: 'earned_at DESC',
    );
    return maps.map((m) => Badge.fromMap(m)).toList();
  }

  /// Returns badges that match a specific condition type
  Future<List<Badge>> getBadgesByCondition(String conditionType) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'badges',
      where: 'condition_type = ? AND is_earned = 0',
      whereArgs: [conditionType],
    );
    return maps.map((m) => Badge.fromMap(m)).toList();
  }

  // UPDATE — Earn a badge

  /// Marks a badge as earned and sets the earned timestamp.
  /// Returns the newly earned badge or null if it was already earned.
  Future<Badge?> earnBadge(String badgeId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('badges', where: 'id = ?', whereArgs: [badgeId]);

    if (maps.isEmpty) return null;
    final badge = Badge.fromMap(maps.first);
    if (badge.isEarned) return null; // Already earned

    badge.isEarned = true;
    badge.earnedAt = DateTime.now().toIso8601String();

    await db.update(
      'badges',
      {'is_earned': 1, 'earned_at': badge.earnedAt},
      where: 'id = ?',
      whereArgs: [badgeId],
    );

    return badge; // Return badge so UI can show the unlock notification
  }

  // Badge unlock checking logic

  /// Checks all streak-type badges and earns any that are now unlocked.
  /// Returns a list of newly earned badges (for unlock notifications).
  Future<List<Badge>> checkStreakBadges(int currentStreak) async {
    final pendingBadges = await getBadgesByCondition('streak');
    final newlyEarned = <Badge>[];

    for (final badge in pendingBadges) {
      if (currentStreak >= badge.conditionValue) {
        final earned = await earnBadge(badge.id);
        if (earned != null) newlyEarned.add(earned);
      }
    }
    return newlyEarned;
  }

  /// Checks all level-type badges and earns any that are now unlocked.
  Future<List<Badge>> checkLevelBadges(int currentLevel) async {
    final pendingBadges = await getBadgesByCondition('level');
    final newlyEarned = <Badge>[];

    for (final badge in pendingBadges) {
      if (currentLevel >= badge.conditionValue) {
        final earned = await earnBadge(badge.id);
        if (earned != null) newlyEarned.add(earned);
      }
    }
    return newlyEarned;
  }

  /// Checks completion count badges
  Future<List<Badge>> checkCompletionBadges(int totalCompletions) async {
    final pendingBadges = await getBadgesByCondition('completion_count');
    final newlyEarned = <Badge>[];

    for (final badge in pendingBadges) {
      if (totalCompletions >= badge.conditionValue) {
        final earned = await earnBadge(badge.id);
        if (earned != null) newlyEarned.add(earned);
      }
    }
    return newlyEarned;
  }

  // INSERT (for adding new badge definitions)

  Future<void> insertBadge(Badge badge) async {
    final db = await _dbHelper.database;
    await db.insert(
      'badges',
      badge.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}