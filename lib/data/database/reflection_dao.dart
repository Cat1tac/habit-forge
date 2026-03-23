import 'package:sqflite/sqflite.dart';
import '../models/reflection.dart';
import 'database_helper.dart';

/// Data Access Object for weekly reflection CRUD operations.
class ReflectionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // CREATE

  /// Inserts a new reflection entry
  Future<void> insertReflection(Reflection reflection) async {
    final db = await _dbHelper.database;
    await db.insert(
      'reflections',
      reflection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ

  /// Returns all reflections sorted by most recent first
  Future<List<Reflection>> getAllReflections() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reflections',
      orderBy: 'week_start DESC',
    );
    return maps.map((m) => Reflection.fromMap(m)).toList();
  }

  /// Returns the reflection for the current week, if any
  Future<Reflection?> getCurrentWeekReflection() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    // Get start of current week (Monday)
    final mondayOffset = now.weekday - 1;
    final weekStart = DateTime(now.year, now.month, now.day - mondayOffset);
    final weekStartStr =
        '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'reflections',
      where: 'week_start = ?',
      whereArgs: [weekStartStr],
    );

    if (maps.isEmpty) return null;
    return Reflection.fromMap(maps.first);
  }

  /// Returns the N most recent reflections
  Future<List<Reflection>> getRecentReflections({int limit = 4}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reflections',
      orderBy: 'week_start DESC',
      limit: limit,
    );
    return maps.map((m) => Reflection.fromMap(m)).toList();
  }

  // UPDATE

  /// Updates an existing reflection (e.g., to add AI insight after generation)
  Future<void> updateReflection(Reflection reflection) async {
    final db = await _dbHelper.database;
    await db.update(
      'reflections',
      reflection.toMap(),
      where: 'id = ?',
      whereArgs: [reflection.id],
    );
  }

  /// Saves only the AI insight field for an existing reflection
  Future<void> saveAiInsight(String reflectionId, String insight) async {
    final db = await _dbHelper.database;
    await db.update(
      'reflections',
      {'ai_insight': insight},
      where: 'id = ?',
      whereArgs: [reflectionId],
    );
  }

  // DELETE

  Future<void> deleteReflection(String reflectionId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'reflections',
      where: 'id = ?',
      whereArgs: [reflectionId],
    );
  }
}