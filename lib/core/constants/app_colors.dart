import 'package:flutter/material.dart';

/// Central color palette for Habit Mastery League
/// All colors reference this file — never use raw hex elsewhere
class AppColors {
  AppColors._(); // Prevent instantiation

  // Primary palette
  static const Color primary = Color(0xFF6C63FF);       // Purple
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3D35CC);

  // Secondary palette
  static const Color accent = Color(0xFFFF6584);        // Pink/coral
  static const Color accentLight = Color(0xFFFF95A9);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);       // Green — streak active
  static const Color warning = Color(0xFFFFC107);       // Amber — shield used
  static const Color danger = Color(0xFFF44336);        // Red — streak broken
  static const Color info = Color(0xFF2196F3);          // Blue — info cards

  // Level colors (deeper purple per level)
  static const List<Color> levelColors = [
    Color(0xFF9E9E9E), // Level 1 — Gray
    Color(0xFF4CAF50), // Level 2 — Green
    Color(0xFF2196F3), // Level 3 — Blue
    Color(0xFF9C27B0), // Level 4 — Purple
    Color(0xFFFF9800), // Level 5 — Orange
    Color(0xFFF44336), // Level 6 — Red
    Color(0xFF00BCD4), // Level 7 — Cyan
    Color(0xFFFFEB3B), // Level 8 — Yellow
    Color(0xFFE91E63), // Level 9 — Pink
    Color(0xFFFFD700), // Level 10 — Gold ⭐
  ];

  // Backgrounds
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color backgroundCard = Color(0xFF16213E);
  static const Color backgroundSurface = Color(0xFF0F3460);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3C1);
  static const Color textMuted = Color(0xFF6B6F82);
}