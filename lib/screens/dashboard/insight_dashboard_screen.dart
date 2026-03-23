// lib/screens/dashboard/insight_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/score_calculator.dart';
import '../../providers/habit_provider.dart';
import '../../providers/streak_provider.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/score_card.dart';

/// Analytics dashboard showing weekly activity chart, scores, and rank.
class InsightDashboardScreen extends StatelessWidget {
  const InsightDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(AppStrings.dashTitle, style: AppTextStyles.headingMedium),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/reflection'),
            child: const Text('+ Reflect', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Consumer2<HabitProvider, StreakProvider>(
        builder: (context, habitProvider, streakProvider, _) {
          final totalXp = habitProvider.totalXp;
          final rank = ScoreCalculator.rankTitle(totalXp);
          final rankEmoji = ScoreCalculator.rankEmoji(totalXp);
          final bestStreak = streakProvider.topCurrentStreak;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank banner
                _buildRankBanner(rank, rankEmoji, totalXp),
                const SizedBox(height: 20),

                // Score cards row
                Row(
                  children: [
                    ScoreCard(
                      label: AppStrings.dashTotalXp,
                      value: '$totalXp',
                      emoji: '⚡',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    ScoreCard(
                      label: AppStrings.dashBestStreak,
                      value: '$bestStreak',
                      emoji: '🔥',
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ScoreCard(
                      label: 'Active Habits',
                      value: '${habitProvider.habits.length}',
                      emoji: '🎯',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    ScoreCard(
                      label: 'Level Avg',
                      value: habitProvider.habits.isEmpty
                          ? '0'
                          : '${(habitProvider.habits.map((h) => h.level).reduce((a, b) => a + b) / habitProvider.habits.length).round()}',
                      emoji: '📈',
                      color: AppColors.accent,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Weekly activity bar chart
                Text(AppStrings.dashTrendTitle, style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                if (habitProvider.habits.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(AppStrings.dashNoData,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge),
                    ),
                  )
                else
                  WeeklyChart(habits: habitProvider.habits),

                const SizedBox(height: 24),

                // Navigation to sub-screens
                _buildQuickActions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankBanner(String rank, String emoji, int totalXp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.6),
            AppColors.primaryDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Rank', style: AppTextStyles.bodySmall),
              Text(rank, style: AppTextStyles.displayMedium),
              Text('$totalXp Total XP', style: AppTextStyles.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _actionChip(context, '🗓️ Heatmap', '/heatmap'),
            _actionChip(context, '🎯 Challenges', '/challenges'),
            _actionChip(context, '🏅 Badges', '/badges'),
            _actionChip(context, '🤖 AI Buddy', '/ai-buddy'),
          ],
        ),
      ],
    );
  }

  Widget _actionChip(BuildContext context, String label, String route) {
    return ActionChip(
      label: Text(label, style: AppTextStyles.labelMedium),
      backgroundColor: AppColors.backgroundCard,
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }
}