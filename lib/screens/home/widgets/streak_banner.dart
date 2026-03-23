import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Compact banner shown on the Home screen displaying the user's
/// top current streak and remaining shield count.
class StreakBanner extends StatelessWidget {
  final int currentStreak;
  final int shieldsRemaining;
  final String habitName;

  const StreakBanner({
    super.key,
    required this.currentStreak,
    required this.shieldsRemaining,
    required this.habitName,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStreak == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.2),
            AppColors.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Flame icon
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),

          // Streak count + habit name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$currentStreak ',
                        style: AppTextStyles.streakStat.copyWith(fontSize: 22),
                      ),
                      TextSpan(
                        text: 'day streak',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  habitName,
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Shield pips
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Shields', style: AppTextStyles.bodySmall),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Icon(
                    Icons.shield,
                    size: 18,
                    color: i < shieldsRemaining
                        ? AppColors.primary
                        : AppColors.textMuted,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}