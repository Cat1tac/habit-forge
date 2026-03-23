import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_log.dart';
import '../../data/database/habit_dao.dart';
import '../../providers/habit_provider.dart';
import '../../providers/streak_provider.dart';

/// Detailed view for a single habit mission.
/// Shows XP progress, streak stats, shields remaining, and completion history.
class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final HabitDao _habitDao = HabitDao();
  List<HabitLog> _logs = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final habit = ModalRoute.of(context)?.settings.arguments as Habit?;
    if (habit != null) _loadLogs(habit.id);
  }

  Future<void> _loadLogs(String habitId) async {
    final logs = await _habitDao.getLogsForHabit(habitId);
    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = ModalRoute.of(context)?.settings.arguments as Habit?;
    if (habit == null) {
      return const Scaffold(body: Center(child: Text('Habit not found')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text('${habit.icon} ${habit.name}',
            style: AppTextStyles.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => _confirmDelete(context, habit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLevelCard(habit),
            const SizedBox(height: 16),
            _buildStatsRow(context, habit),
            const SizedBox(height: 16),
            _buildShieldsCard(habit),
            const SizedBox(height: 24),
            Text(AppStrings.detailHistory, style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_logs.isEmpty)
              _buildNoLogs()
            else
              _buildLogList(),
          ],
        ),
      ),
    );
  }

  // Level & XP card
  Widget _buildLevelCard(Habit habit) {
    final levelColor = AppColors.levelColors[
        (habit.level - 1).clamp(0, AppColors.levelColors.length - 1)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: levelColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LVL ${habit.level}',
                  style: AppTextStyles.levelBadge,
                ),
              ),
              const Spacer(),
              Text(
                '${habit.xp} / ${habit.xpToNextLevel} XP',
                style: AppTextStyles.xpStat,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: habit.levelProgress.clamp(0.0, 1.0),
            backgroundColor: AppColors.backgroundDark,
            progressColor: levelColor,
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Text(
            habit.level < 10
                ? '${habit.xpToNextLevel - habit.xp} XP to Level ${habit.level + 1}'
                : 'MAX LEVEL 🌟',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  // Stats row (streak, best streak, completions)
  Widget _buildStatsRow(BuildContext context, Habit habit) {
    final streak = context.watch<StreakProvider>().streakFor(habit.id);
    return Row(
      children: [
        _buildStatBox(
          '${streak?.currentStreak ?? 0}',
          AppStrings.detailStreak,
          '🔥',
          AppColors.warning,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          '${streak?.longestStreak ?? 0}',
          AppStrings.detailLongest,
          '⭐',
          AppColors.primary,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          '${_logs.length}',
          AppStrings.detailTotalLogs,
          '✅',
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, String emoji, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    AppTextStyles.statLarge.copyWith(color: color)),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  // Shields card
  Widget _buildShieldsCard(Habit habit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.detailShields, style: AppTextStyles.headingSmall),
              Text(
                'Protects your streak if you miss a day',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          // Shield pip indicators
          Row(
            children: List.generate(3, (i) {
              final active = i < habit.streakShields;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.shield,
                  color: active ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Log history list
  Widget _buildLogList() {
    return Column(
      children: _logs.take(10).map((log) {
        final date = DateTime.parse(log.completedDate);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppColors.success.withOpacity(0.2),
            child: const Icon(Icons.check, color: AppColors.success, size: 18),
          ),
          title: Text(AppDateUtils.formatRelative(date),
              style: AppTextStyles.bodyLarge),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('+${log.score}', style: AppTextStyles.labelMedium),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoLogs() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No completions yet.\nComplete this habit to start your history!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  // Delete confirmation
  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text(AppStrings.detailDeleteTitle,
            style: AppTextStyles.headingSmall),
        content: Text(AppStrings.detailDeleteBody,
            style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.detailDeleteCancel,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.detailDeleteConfirm,
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<HabitProvider>().deleteHabit(habit.id);
      Navigator.pop(context);
    }
  }
}