import '../models/habit.dart';
import '../models/habit_log.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/utils/date_utils.dart';

/// Data Access Object for Habit CRUD operations
class HabitDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // CREATE
  /// Inserts a new habit into the database
  Future<void> insertHabit(Habit habit) async {
    final db = await _dbHelper.database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Logs a habit completion for a specific date
  Future<void> logCompletion(HabitLog log) async {
    final db = await _dbHelper.database;
    await db.insert(
      'habit_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ
  /// Returns all active habits
  Future<List<Habit>> getAllHabits() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'habits',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Habit.fromMap(m)).toList();
  }

  /// Returns a single habit by ID
  Future<Habit?> getHabitById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('habits', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  /// Returns all completion logs for a habit
  Future<List<HabitLog>> getLogsForHabit(String habitId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_date DESC',
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  /// Checks if habit was completed on a specific date
  Future<bool> isCompletedOnDate(String habitId, DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    final maps = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND completed_date LIKE ?',
      whereArgs: [habitId, '$dateStr%'],
    );
    return maps.isNotEmpty;
  }

  /// Returns completion map for heatmap: {date: completionScore}
  Future<Map<DateTime, int>> getCompletionMap(String habitId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );

    final result = <DateTime, int>{};
    for (final m in maps) {
      final date = DateTime.parse(m['completed_date'] as String);
      result[DateTime(date.year, date.month, date.day)] =
          m['score'] as int? ?? 100;
    }
    return result;
  }

  // UPDATE
  /// Updates habit details
  Future<void> updateHabit(Habit habit) async {
    final db = await _dbHelper.database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  // DELETE
  /// Soft deletes a habit (sets is_active = 0)
  Future<void> archiveHabit(String habitId) async {
    final db = await _dbHelper.database;
    await db.update(
      'habits',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  /// Permanently deletes a habit and all its logs
  Future<void> deleteHabit(String habitId) async {
    final db = await _dbHelper.database;
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [habitId]);
    await db.delete('habits', where: 'id = ?', whereArgs: [habitId]);
  }

  /// Returns the total number of habit completions logged in the current week
  /// (Monday 00:00:00 to today 23:59:59) across all habits.
  Future<int> getWeeklyCompletionCount() async {
    final db = await _dbHelper.database;

    // Get the Monday of the current week as a date string
    final weekStart = AppDateUtils.toIsoDate(AppDateUtils.startOfCurrentWeek());
    final weekEnd = AppDateUtils.toIsoDate(
      AppDateUtils.startOfCurrentWeek().add(const Duration(days: 6)),
    );

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM habit_logs
      WHERE completed_date >= ? AND completed_date <= ?
    ''', ['$weekStart 00:00:00', '$weekEnd 23:59:59']);

    return result.first['count'] as int? ?? 0;
  }

  /// Returns the weekly completion rate as an integer 0–100.
  /// [totalPossible] = number of active habits × 7 days.
  Future<int> getWeeklyCompletionRate({required int totalPossible}) async {
    if (totalPossible == 0) return 0;
    final completed = await getWeeklyCompletionCount();
    return ((completed / totalPossible) * 100).round().clamp(0, 100);
  }
}