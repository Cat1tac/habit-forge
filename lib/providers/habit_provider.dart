import 'package:flutter/foundation.dart';
import '../data/models/habit.dart';
import '../data/models/habit_log.dart';
import '../data/database/habit_dao.dart';
import '../core/utils/streak_calculator.dart';
import 'package:uuid/uuid.dart';

/// Manages all habit state and exposes actions to the UI layer
class HabitProvider extends ChangeNotifier {
  final HabitDao _habitDao = HabitDao();

  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns habits that are due today based on frequency
  List<Habit> get todaysHabits =>
      _habits.where((h) => h.frequency == 'daily').toList();

  /// Returns total XP across all habits
  int get totalXp => _habits.fold(0, (sum, h) => sum + h.xp);

  // Load habits from database
  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _habitDao.getAllHabits();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load habits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new habit
  Future<void> createHabit(Habit habit) async {
    try {
      await _habitDao.insertHabit(habit);
      _habits.insert(0, habit);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create habit: $e';
      notifyListeners();
    }
  }

  // Mark habit as complete for today
  Future<void> completeHabit(String habitId, {int streak = 0}) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    
    // Calculate score based on streak
    final score = StreakCalculator.calculateDayScore(
      currentStreak: streak,
    );

    // Create completion log
    final log = HabitLog(
      id: const Uuid().v4(),
      habitId: habitId,
      completedDate: DateTime.now().toIso8601String(),
      score: score,
    );

    try {
      await _habitDao.logCompletion(log);
      
      // Award XP — 10 base + streak bonus
      final xpGained = 10 + (streak ~/ 7) * 5;
      habit.awardXp(xpGained);
      
      await _habitDao.updateHabit(habit);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to log completion: $e';
      notifyListeners();
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitDao.deleteHabit(habitId);
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete habit: $e';
      notifyListeners();
    }
  }

  //archive a habit
 Future<void> archiveHabit(String habitId) async {
   await _habitDao.archiveHabit(habitId);
   _habits.removeWhere((h) => h.id == habitId);
   notifyListeners();
 }
}