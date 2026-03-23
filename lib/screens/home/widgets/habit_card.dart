import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/habit.dart';
import '../../../providers/streak_provider.dart';

/// Card widget displaying a single habit mission on the Home screen.
/// Shows the icon, name, level badge, XP progress bar, streak counter,
/// and a complete button.
class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    this.onTap,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  bool _isCompleted = false; // Tracks same-session completion

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onComplete() {
    if (_isCompleted) return; // Prevent double-tap
    setState(() => _isCompleted = true);
    _bounceController.forward().then((_) => _bounceController.reverse());
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final levelColor = AppColors.levelColors[
        (habit.level - 1).clamp(0, AppColors.levelColors.length - 1)];

    final streak =
        context.watch<StreakProvider>().streakFor(habit.id);
    final currentStreak = streak?.currentStreak ?? 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isCompleted
                ? AppColors.success.withOpacity(0.5)
                : levelColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: levelColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + name + level badge + complete button
              Row(
                children: [
                  // Habit icon in colored circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        habit.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + frequency
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name,
                            style: AppTextStyles.headingSmall,
                            overflow: TextOverflow.ellipsis),
                        Text(
                          habit.frequency.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'LVL ${habit.level}',
                      style: AppTextStyles.levelBadge,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Complete button with bounce animation
                  ScaleTransition(
                    scale: _bounceAnim,
                    child: GestureDetector(
                      onTap: _onComplete,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isCompleted
                                      ? AppColors.success
                                      : AppColors.primary)
                                  .withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isCompleted ? Icons.check : Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // XP progress bar
              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      lineHeight: 6,
                      percent: habit.levelProgress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.backgroundDark,
                      progressColor: levelColor,
                      barRadius: const Radius.circular(3),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${habit.xp}/${habit.xpToNextLevel} XP',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),

              // Bottom row: streak indicator
              if (currentStreak > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '$currentStreak day streak',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}