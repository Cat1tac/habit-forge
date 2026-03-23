import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typography system for Habit Mastery League.
/// All screens reference these styles — never use raw TextStyle inline.
/// Font: Poppins (add to pubspec.yaml under fonts or use google_fonts package)
class AppTextStyles {
  AppTextStyles._(); // Prevent instantiation

  // Display / Hero text (large titles, splash screen)

  /// 32px bold white — used for screen hero titles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// 28px bold white — used for section headers
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // Heading text

  /// 22px semibold — used for card titles and screen section headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 18px semibold — used for subsection titles
  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 16px semibold — used for habit names and card headers
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Body text

  /// 15px regular — main readable content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  /// 13px regular — secondary descriptions, subtitles
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  // Label / Chip text

  /// 12px medium — badge labels, tags, chips
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  /// 11px bold uppercase — difficulty labels, status pills
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );

  // Number / Stat text

  /// 40px extra-bold — streak numbers, big stats
  static const TextStyle statHuge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  /// 24px bold — medium stat numbers
  static const TextStyle statLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // Accent / Colored variants (factory methods)

  /// Returns a style colored with the given color
  static TextStyle colored(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  /// Streak counter style — orange/fire colored
  static TextStyle get streakStat =>
      statHuge.copyWith(color: AppColors.warning);

  /// XP counter style — accent purple
  static TextStyle get xpStat =>
      statLarge.copyWith(color: AppColors.primary);

  /// Level badge style — white bold inside colored container
  static TextStyle get levelBadge => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  // AI Buddy message styles

  /// AI message body text — slightly italic for personality
  static const TextStyle aiBuddyMessage = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.7,
    fontStyle: FontStyle.italic,
  );

  /// AI micro-goal bold call-to-action
  static const TextStyle aiMicroGoal = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.5,
  );
}