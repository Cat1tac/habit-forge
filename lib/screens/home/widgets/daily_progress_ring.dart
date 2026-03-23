import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Circular progress ring showing how many of today's habits are complete.
/// Displayed prominently on the Home screen.
class DailyProgressRing extends StatelessWidget {
  final int completed;
  final int total;

  const DailyProgressRing({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final isAllDone = completed >= total && total > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Ring indicator
          CircularPercentIndicator(
            radius: 52,
            lineWidth: 10,
            percent: percent,
            backgroundColor: AppColors.backgroundDark,
            progressColor:
                isAllDone ? AppColors.success : AppColors.primary,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isAllDone ? '🎉' : '$completed/$total',
                  style: isAllDone
                      ? const TextStyle(fontSize: 24)
                      : AppTextStyles.statLarge,
                ),
                if (!isAllDone)
                  Text('done', style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Text breakdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAllDone
                      ? 'All missions complete!'
                      : 'Daily Progress',
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  isAllDone
                      ? 'You\'re on fire today 🔥 Keep the streak alive!'
                      : '${total - completed} mission${total - completed == 1 ? '' : 's'} remaining today.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                // Mini progress bar
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: AppColors.backgroundDark,
                  color:
                      isAllDone ? AppColors.success : AppColors.primary,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}