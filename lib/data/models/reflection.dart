import 'package:uuid/uuid.dart';
import '../../core/utils/date_utils.dart';

/// Stores the user's weekly self-reflection entry including
/// mood, highlights, struggles, and AI-generated insight.
class Reflection {
  final String id;
  final String weekStart;       // ISO date string
  final String weekEnd;         // ISO date string
  int mood;                     // 1–5 rating
  String? highlights;           // Freeform text
  String? struggles;            // Freeform text
  String? aiInsight;            // AI-generated analysis (set after API call)
  final int totalScore;         // Calculated weekly score
  final int habitsCompleted;    // Total completions in the week
  final String createdAt;

  Reflection({
    String? id,
    String? weekStart,
    String? weekEnd,
    this.mood = 3,
    this.highlights,
    this.struggles,
    this.aiInsight,
    this.totalScore = 0,
    this.habitsCompleted = 0,
    String? createdAt,
  })  : id = id ?? const Uuid().v4(),
        weekStart = weekStart ??
            AppDateUtils.toIsoDate(AppDateUtils.startOfCurrentWeek()),
        weekEnd = weekEnd ??
            AppDateUtils.toIsoDate(
              AppDateUtils.startOfCurrentWeek().add(const Duration(days: 6)),
            ),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  // Display helpers

  /// Returns the emoji representing the mood score
  String get moodEmoji {
    switch (mood) {
      case 1: return '😞';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '😊';
      case 5: return '🤩';
      default: return '😐';
    }
  }

  /// Returns a formatted week range string
  String get weekRangeDisplay {
    return AppDateUtils.formatWeekRange(DateTime.parse(weekStart));
  }

  // SQLite serialization

  Map<String, dynamic> toMap() => {
        'id': id,
        'week_start': weekStart,
        'week_end': weekEnd,
        'mood': mood,
        'highlights': highlights,
        'struggles': struggles,
        'ai_insight': aiInsight,
        'total_score': totalScore,
        'habits_completed': habitsCompleted,
        'created_at': createdAt,
      };

  factory Reflection.fromMap(Map<String, dynamic> map) => Reflection(
        id: map['id'],
        weekStart: map['week_start'],
        weekEnd: map['week_end'],
        mood: map['mood'] ?? 3,
        highlights: map['highlights'],
        struggles: map['struggles'],
        aiInsight: map['ai_insight'],
        totalScore: map['total_score'] ?? 0,
        habitsCompleted: map['habits_completed'] ?? 0,
        createdAt: map['created_at'],
      );
}