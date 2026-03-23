// lib/screens/badges/badges_screen.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/score_calculator.dart';
import '../../data/database/badge_dao.dart';
import '../../data/database/streak_dao.dart';
import '../../data/models/badge.dart';

/// Grid display of all badges — earned ones are shown in full color,
/// locked ones are shown with a progress bar toward the requirement.
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with SingleTickerProviderStateMixin {
  final BadgeDao _badgeDao = BadgeDao();
  final StreakDao _streakDao = StreakDao();

  List<Badge> _badges = [];
  int _topStreak = 0;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final badges = await _badgeDao.getAllBadges();
    final streak = await _streakDao.getGlobalBestStreak();
    if (mounted) {
      setState(() {
        _badges = badges;
        _topStreak = streak;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final earned = _badges.where((b) => b.isEarned).toList();
    final locked = _badges.where((b) => !b.isEarned).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(AppStrings.badgesTitle, style: AppTextStyles.headingMedium),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: '${AppStrings.badgesEarned} (${earned.length})'),
            Tab(text: '${AppStrings.badgesLocked} (${locked.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGrid(earned, isEarned: true),
                _buildGrid(locked, isEarned: false),
              ],
            ),
    );
  }

  Widget _buildGrid(List<Badge> badges, {required bool isEarned}) {
    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isEarned ? '🏅' : '🔒',
                style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              isEarned
                  ? 'No badges earned yet. Keep going!'
                  : 'All badges unlocked! 🎉',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (_, i) => _buildBadgeTile(badges[i], isEarned: isEarned),
    );
  }

  Widget _buildBadgeTile(Badge badge, {required bool isEarned}) {
    final progress = _getProgress(badge);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEarned
              ? AppColors.warning.withOpacity(0.4)
              : AppColors.textMuted.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: isEarned
            ? [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with earned/locked overlay
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 44,
                    color: isEarned ? null : Colors.transparent,
                  ),
                ),
                if (!isEarned)
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      AppColors.textMuted.withOpacity(0.6),
                      BlendMode.srcATop,
                    ),
                    child: Text(badge.icon,
                        style: const TextStyle(fontSize: 44)),
                  ),
                if (!isEarned)
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text('🔒', style: TextStyle(fontSize: 18)),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              badge.name,
              style: AppTextStyles.headingSmall.copyWith(
                color: isEarned ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            Text(
              badge.conditionDescription,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Progress bar for locked badges
            if (!isEarned) ...[
              const SizedBox(height: 10),
              LinearPercentIndicator(
                lineHeight: 5,
                percent: progress,
                backgroundColor: AppColors.backgroundDark,
                progressColor: AppColors.primary,
                barRadius: const Radius.circular(3),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary),
              ),
            ],

            // Earned date
            if (isEarned && badge.earnedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Earned ✅',
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Returns 0.0–1.0 progress toward badge unlock condition
  double _getProgress(Badge badge) {
    switch (badge.conditionType) {
      case 'streak':
        return ScoreCalculator.badgeProgress(
          currentValue: _topStreak,
          targetValue: badge.conditionValue,
        );
      default:
        return 0.0;
    }
  }
}