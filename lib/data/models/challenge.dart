import 'package:uuid/uuid.dart';
import '../../core/utils/date_utils.dart';

/// Represents a time-limited performance challenges
class Challenge {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  int currentValue;
  final String challengeType;  // 'streak', 'completion', 'xp', 'level'
  final String difficulty;     // 'easy', 'medium', 'hard'
  final String startDate;
  final String endDate;
  bool isCompleted;
  final int rewardXp;

  Challenge({
    String? id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    required this.challengeType,
    this.difficulty = 'medium',
    String? startDate,
    String? endDate,
    this.isCompleted = false,
    this.rewardXp = 50,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? AppDateUtils.todayIso(),
        endDate = endDate ??
            AppDateUtils.toIsoDate(
              DateTime.now().add(const Duration(days: 7)),
            );

  // Progress helpers

  /// Completion percentage 0.0 to 1.0
  double get progress =>
      targetValue == 0 ? 1.0 : (currentValue / targetValue).clamp(0.0, 1.0);

  /// Returns true if the end date has passed
  bool get isExpired {
    final end = DateTime.parse(endDate);
    return DateTime.now().isAfter(end);
  }

  /// Days remaining until challenge expires
  int get daysRemaining {
    final end = DateTime.parse(endDate);
    final remaining = end.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  // SQLite serialization

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'target_value': targetValue,
        'current_value': currentValue,
        'challenge_type': challengeType,
        'difficulty': difficulty,
        'start_date': startDate,
        'end_date': endDate,
        'is_completed': isCompleted ? 1 : 0,
        'reward_xp': rewardXp,
      };

  factory Challenge.fromMap(Map<String, dynamic> map) => Challenge(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        targetValue: map['target_value'],
        currentValue: map['current_value'] ?? 0,
        challengeType: map['challenge_type'],
        difficulty: map['difficulty'] ?? 'medium',
        startDate: map['start_date'],
        endDate: map['end_date'],
        isCompleted: (map['is_completed'] ?? 0) == 1,
        rewardXp: map['reward_xp'] ?? 50,
      );
}