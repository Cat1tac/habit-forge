import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/score_calculator.dart';
import '../../providers/habit_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/challenge_provider.dart';

/// Shows adaptive goals personalized to the user's performance.
/// Tapping "Generate New Challenges" creates fresh challenges from current stats.
class AdaptiveGoalsScreen extends StatelessWidget {
  const AdaptiveGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(AppStrings.adaptiveTitle, style: AppTextStyles.headingMedium),
      ),
      body: Consumer3<HabitProvider, StreakProvider, ChallengeProvider>(
        builder: (context, habitProvider, streakProvider, challengeProvider, _) {
          final totalXp = habitProvider.totalXp;
          final topStreak = streakProvider.topCurrentStreak;
          final habitCount = habitProvider.habits.length;

          // Compute adaptive targets based on current performance
          final streakGoal = (topStreak * 1.2).round().clamp(3, 90);
          final completionGoal = (habitCount * 7 * 0.8).round(); // 80% of weekly max
          final xpGoal = (totalXp * 0.15).round().clamp(50, 500);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subheader
                Text(AppStrings.adaptiveSubtitle, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 24),

                // Stats context card
                _buildContextCard(totalXp, topStreak, habitCount),
                const SizedBox(height: 24),

                // Goal cards
                Text('Your Adaptive Targets', style: AppTextStyles.headingSmall),
                const SizedBox(height: 14),
                _buildGoalCard(
                  emoji: '🔥',
                  title: AppStrings.adaptiveStreak,
                  current: topStreak,
                  target: streakGoal,
                  color: AppColors.warning,
                  unit: 'days',
                ),
                const SizedBox(height: 12),
                _buildGoalCard(
                  emoji: '✅',
                  title: AppStrings.adaptiveCompletion,
                  current: 0, // TODO: compute from real weekly data
                  target: completionGoal,
                  color: AppColors.success,
                  unit: 'completions',
                ),
                const SizedBox(height: 12),
                _buildGoalCard(
                  emoji: '⚡',
                  title: AppStrings.adaptiveXp,
                  current: totalXp % 100, // XP earned this week (stub)
                  target: xpGoal,
                  color: AppColors.primary,
                  unit: 'XP',
                ),

                const SizedBox(height: 32),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await challengeProvider.generateAdaptiveChallenges(
                        currentStreak: topStreak,
                        weeklyCompletionRate: 70,
                        totalXp: totalXp,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎯 New challenges generated!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate New Challenges'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContextCard(int totalXp, int topStreak, int habitCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat('${ScoreCalculator.rankEmoji(totalXp)} ${ScoreCalculator.rankTitle(totalXp)}', 'Rank'),
          _miniStat('$topStreak', 'Top Streak'),
          _miniStat('$habitCount', 'Habits'),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.statLarge),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildGoalCard({
    required String emoji,
    required String title,
    required int current,
    required int target,
    required Color color,
    required String unit,
  }) {
    final progress = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.headingSmall),
              const Spacer(),
              Text('$current / $target $unit',
                  style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: progress,
            backgroundColor: AppColors.backgroundDark,
            progressColor: color,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.adaptiveCurrentPace} ${_paceMessage(current, target)}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  String _paceMessage(int current, int target) {
    if (target == 0) return 'No goal set';
    final pct = (current / target * 100).round();
    if (pct >= 100) return '✅ Goal reached!';
    if (pct >= 70) return '💪 Almost there!';
    if (pct >= 40) return '📈 Good progress';
    return '🚀 Keep going!';
  }
}