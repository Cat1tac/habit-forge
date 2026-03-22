import 'package:uuid/uuid.dart';

/// Represents a single habit mission in the league
class Habit {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final String frequency;   // 'daily', 'weekly', 'custom'
  int level;                // 1–10, upgrades with XP
  int xp;                   // Experience points accumulated
  int streakShields;        // Protects streak from being broken
  final String createdAt;
  bool isActive;

  Habit({
    String? id,
    required this.name,
    this.description,
    this.icon = '⭐',
    this.color = '#6C63FF',
    this.frequency = 'daily',
    this.level = 1,
    this.xp = 0,
    this.streakShields = 3,
    String? createdAt,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  // XP thresholds for each level (level n requires n * 100 XP)
  int get xpToNextLevel => level * 100;
  double get levelProgress => xp / xpToNextLevel;

  /// Awards XP and levels up if threshold is crossed
  void awardXp(int points) {
    xp += points;
    while (xp >= xpToNextLevel && level < 10) {
      xp -= xpToNextLevel;
      level++;
    }
  }

  // SQLite serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'level': level,
      'xp': xp,
      'streak_shields': streakShields,
      'created_at': createdAt,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'] ?? '⭐',
      color: map['color'] ?? '#6C63FF',
      frequency: map['frequency'] ?? 'daily',
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      streakShields: map['streak_shields'] ?? 3,
      createdAt: map['created_at'],
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }

  Habit copyWith({
    String? name,
    String? description,
    String? icon,
    String? color,
    String? frequency,
    int? level,
    int? xp,
    int? streakShields,
    bool? isActive,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streakShields: streakShields ?? this.streakShields,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}