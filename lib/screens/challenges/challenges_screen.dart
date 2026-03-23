import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/challenge.dart';
import '../../providers/challenge_provider.dart';

/// Displays active and completed challenges with progress bars.
/// Includes a "generate new challenges" action.
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().loadChallenges();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(AppStrings.challengesTitle, style: AppTextStyles.headingMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/adaptive-goals'),
            child: const Text('Adaptive Goals',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildChallengeList(provider.activeChallenges, active: true),
              _buildChallengeList(provider.completedChallenges, active: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChallengeList(List<Challenge> challenges, {required bool active}) {
    if (challenges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(active ? '🎯' : '🏆',
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                active ? AppStrings.challengesNoActive : 'No completed challenges yet.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (_, i) => _buildChallengeCard(challenges[i], active: active),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, {required bool active}) {
    final diffColor = _difficultyColor(challenge.difficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: challenge.isCompleted
              ? AppColors.success.withOpacity(0.4)
              : diffColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(challenge.title, style: AppTextStyles.headingSmall),
              ),
              // Difficulty badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: diffColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  challenge.difficulty.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(color: diffColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(challenge.description, style: AppTextStyles.bodyLarge),
          const SizedBox(height: 14),

          // Progress bar
          LinearPercentIndicator(
            lineHeight: 8,
            percent: challenge.progress,
            backgroundColor: AppColors.backgroundDark,
            progressColor: challenge.isCompleted ? AppColors.success : AppColors.primary,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),

          // Footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.currentValue} / ${challenge.targetValue}',
                style: AppTextStyles.bodySmall,
              ),
              if (active && !challenge.isExpired)
                Text(
                  '${challenge.daysRemaining}d left',
                  style: AppTextStyles.bodySmall,
                )
              else if (challenge.isExpired && !challenge.isCompleted)
                Text('Expired', style: TextStyle(color: AppColors.danger, fontSize: 12))
              else
                Text(
                  '${AppStrings.challengesReward}: +${challenge.rewardXp} XP',
                  style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return AppColors.success;
      case 'medium': return AppColors.warning;
      case 'hard': return AppColors.danger;
      default: return AppColors.info;
    }
  }
}