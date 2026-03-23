// lib/providers/ai_provider.dart

import 'package:flutter/foundation.dart';
import '../data/models/habit.dart';
import '../data/models/streak.dart';
import '../services/ai_service.dart';

/// Manages the state for the AI Habit Buddy feature.
/// Caches messages so they don't re-fetch on every build.
class AiProvider extends ChangeNotifier {
  final AiService _aiService = AiService();

  String? _microGoal;
  String? _pepTalk;
  String? _weeklyInsight;

  bool _isLoadingGoal = false;
  bool _isLoadingPep = false;
  bool _isLoadingInsight = false;

  String? _goalError;
  String? _pepError;

  // Getters
  String? get microGoal => _microGoal;
  String? get pepTalk => _pepTalk;
  String? get weeklyInsight => _weeklyInsight;

  bool get isLoadingGoal => _isLoadingGoal;
  bool get isLoadingPep => _isLoadingPep;
  bool get isLoadingInsight => _isLoadingInsight;

  String? get goalError => _goalError;
  String? get pepError => _pepError;

  // Fetch daily micro-goal for a specific habit

  Future<void> fetchMicroGoal({
    required Habit habit,
    required Streak streak,
  }) async {
    _isLoadingGoal = true;
    _goalError = null;
    notifyListeners();

    try {
      _microGoal = await _aiService.generateMicroGoal(
        habit: habit,
        streak: streak,
      );
    } catch (e) {
      _goalError = 'Could not load micro-goal.';
      _microGoal = AiService.fallbackGoal;
    } finally {
      _isLoadingGoal = false;
      notifyListeners();
    }
  }

  // Fetch pep talk based on overall stats

  Future<void> fetchPepTalk({
    required List<Habit> habits,
    required int totalStreakDays,
    required int weeklyCompletionRate,
  }) async {
    _isLoadingPep = true;
    _pepError = null;
    notifyListeners();

    try {
      _pepTalk = await _aiService.generatePepTalk(
        habits: habits,
        totalStreakDays: totalStreakDays,
        weeklyCompletionRate: weeklyCompletionRate,
      );
    } catch (e) {
      _pepError = 'Could not load pep talk.';
      _pepTalk = AiService.fallbackPep;
    } finally {
      _isLoadingPep = false;
      notifyListeners();
    }
  }

  // Fetch weekly insight after reflection is submitted

  Future<void> fetchWeeklyInsight({
    required List<Habit> habits,
    required int completedCount,
    required int totalPossible,
    String? userMoodNote,
  }) async {
    _isLoadingInsight = true;
    notifyListeners();

    try {
      _weeklyInsight = await _aiService.generateWeeklyInsight(
        habits: habits,
        completedCount: completedCount,
        totalPossible: totalPossible,
        userMoodNote: userMoodNote,
      );
    } catch (e) {
      _weeklyInsight = AiService.fallbackInsight;
    } finally {
      _isLoadingInsight = false;
      notifyListeners();
    }
  }

  // Clear cached messages (call to force a refresh)
  void clearGoal() {
    _microGoal = null;
    notifyListeners();
  }

  void clearPep() {
    _pepTalk = null;
    notifyListeners();
  }

  void clearAll() {
    _microGoal = null;
    _pepTalk = null;
    _weeklyInsight = null;
    notifyListeners();
  }
}