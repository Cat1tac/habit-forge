import 'package:uuid/uuid.dart';

/// Records a single habit completion event
class HabitLog {
  final String id;
  final String habitId;
  final String completedDate;
  final int score;
  final String? notes;

  HabitLog({
    String? id,
    required this.habitId,
    required this.completedDate,
    this.score = 100,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'habit_id': habitId,
        'completed_date': completedDate,
        'score': score,
        'notes': notes,
      };

  factory HabitLog.fromMap(Map<String, dynamic> map) => HabitLog(
        id: map['id'],
        habitId: map['habit_id'],
        completedDate: map['completed_date'],
        score: map['score'] ?? 100,
        notes: map['notes'],
      );
}