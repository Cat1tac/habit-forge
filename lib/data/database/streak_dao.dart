import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/streak.dart';
import 'database_helper.dart';

/// Handles streak creation, updates, and shield management.
class StreakDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // CREATE

  /// Creates a new streak record for a habit.
  /// Called automatically when a habit is first created.
  Future<void> insertStreak(Streak streak) async {
    final db = await _dbHelper.database;
    await db.insert(
      'streaks',
      streak.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Creates a default streak entry for a new habit
  Future<Streak> createDefaultStreak(String habitId) async {
    final streak = Streak(
      id: const Uuid().v4(),
      habitId: habitId,
    );
    await insertStreak(streak);
    return streak;
  }

  // READ

  /// Returns the streak record for a specific habit
  Future<Streak?> getStreakForHabit(String habitId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'streaks',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    if (maps.isEmpty) return null;
    return Streak.fromMap(maps.first);
  }

  /// Returns all streaks across all habits
  Future<List<Streak>> getAllStreaks() async {
    final db = await _dbHelper.database;
    final maps = await db.query('streaks');
    return maps.map((m) => Streak.fromMap(m)).toList();
  }

  /// Returns the global best streak across all habits
  Future<int> getGlobalBestStreak() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT MAX(longest_streak) as max_streak FROM streaks',
    );
    return result.first['max_streak'] as int? ?? 0;
  }

  // UPDATE

  /// Increments the current streak by 1 and updates longest if needed.
  Future<void> incrementStreak(String habitId, String completedDate) async {
    final streak = await getStreakForHabit(habitId);
    if (streak == null) return;

    streak.currentStreak += 1;
    streak.lastCompleted = completedDate;

    // Update longest streak if current surpasses it
    if (streak.currentStreak > streak.longestStreak) {
      streak.longestStreak = streak.currentStreak;
    }

    await updateStreak(streak);
  }

  /// Activates a shield to protect the streak from breaking.
  /// Decrements shield count and preserves current streak.
  Future<bool> activateShield(String habitId) async {
    final streak = await getStreakForHabit(habitId);
    if (streak == null) return false;

    // Check if shields are available (habits start with 3)
    final habit = await _getHabitShieldCount(habitId);
    if (habit <= 0) return false;

    streak.shieldsUsed += 1;

    // Decrement the habit's shield count
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE habits SET streak_shields = streak_shields - 1 WHERE id = ?',
      [habitId],
    );

    await updateStreak(streak);
    return true;
  }

  /// Resets current streak to 0 (called when a day is missed without a shield)
  Future<void> resetStreak(String habitId) async {
    final db = await _dbHelper.database;
    await db.update(
      'streaks',
      {'current_streak': 0},
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
  }

  /// Full update of a streak record
  Future<void> updateStreak(Streak streak) async {
    final db = await _dbHelper.database;
    await db.update(
      'streaks',
      streak.toMap(),
      where: 'id = ?',
      whereArgs: [streak.id],
    );
  }

  // DELETE

  /// Deletes the streak record for a habit (called when habit is deleted)
  Future<void> deleteStreakForHabit(String habitId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'streaks',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
  }

  // Private helpers

  Future<int> _getHabitShieldCount(String habitId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'habits',
      columns: ['streak_shields'],
      where: 'id = ?',
      whereArgs: [habitId],
    );
    if (result.isEmpty) return 0;
    return result.first['streak_shields'] as int? ?? 0;
  }
}