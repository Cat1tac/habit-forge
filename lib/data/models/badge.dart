import 'package:uuid/uuid.dart';

/// Represents a milestone achievement badge.
class Badge {
  final String id;
  final String? habitId;     // null means global badge
  final String name;
  final String description;
  final String icon;
  final String conditionType;   // 'streak', 'level', 'completion_count', 'xp'
  final int conditionValue;     // threshold to earn the badge
  String? earnedAt;             // ISO timestamp when earned, null if not yet
  bool isEarned;

  Badge({
    String? id,
    this.habitId,
    required this.name,
    required this.description,
    this.icon = '🏅',
    required this.conditionType,
    required this.conditionValue,
    this.earnedAt,
    this.isEarned = false,
  }) : id = id ?? const Uuid().v4();

  // Computed helpers

  /// Returns a human-readable description of unlock condition
  String get conditionDescription {
    switch (conditionType) {
      case 'streak':
        return 'Reach a $conditionValue-day streak';
      case 'level':
        return 'Reach Level $conditionValue on any habit';
      case 'completion_count':
        return 'Log $conditionValue total completions';
      case 'xp':
        return 'Earn $conditionValue total XP';
      default:
        return 'Complete the challenge';
    }
  }

  // SQLite serialization

  Map<String, dynamic> toMap() => {
        'id': id,
        'habit_id': habitId,
        'name': name,
        'description': description,
        'icon': icon,
        'condition_type': conditionType,
        'condition_value': conditionValue,
        'earned_at': earnedAt,
        'is_earned': isEarned ? 1 : 0,
      };

  factory Badge.fromMap(Map<String, dynamic> map) => Badge(
        id: map['id'],
        habitId: map['habit_id'],
        name: map['name'],
        description: map['description'],
        icon: map['icon'] ?? '🏅',
        conditionType: map['condition_type'],
        conditionValue: map['condition_value'],
        earnedAt: map['earned_at'],
        isEarned: (map['is_earned'] ?? 0) == 1,
      );
}