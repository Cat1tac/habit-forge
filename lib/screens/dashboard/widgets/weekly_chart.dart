import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';

/// Bar chart showing daily habit completion counts for the current week.
/// Each bar represents one day (Mon–Sun), colored by completion status.
class WeeklyChart extends StatelessWidget {
  final List<Habit> habits;

  const WeeklyChart({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    // In a full implementation, completion data comes from the database.
    // Here we build a placeholder structure showing day labels and bar stubs.
    // Replace _getDailyCompletions() with a real DB query in production.
    final weekDays = AppDateUtils.currentWeekDays();
    final completions = _getDailyCompletions(weekDays);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (habits.length + 1).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.round()} habits',
                AppTextStyles.labelSmall.copyWith(color: Colors.white),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final idx = value.toInt();
                  if (idx < 0 || idx >= days.length) return const SizedBox();
                  final isToday =
                      AppDateUtils.isToday(weekDays[idx]);
                  return Text(
                    days[idx],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isToday ? AppColors.primary : AppColors.textMuted,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.textMuted.withOpacity(0.2),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final isToday = AppDateUtils.isToday(weekDays[i]);
            final count = completions[i].toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count,
                  color: isToday
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.5),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: habits.length.toDouble(),
                    color: AppColors.backgroundDark,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Placeholder: returns a list of completion counts per day.
  /// TODO: Replace with actual DB query for accurate data.
  List<int> _getDailyCompletions(List<DateTime> weekDays) {
    // Stub data — connect to HabitDao.getCompletionMap() for real values
    return List.generate(7, (i) {
      final day = weekDays[i];
      if (day.isAfter(DateTime.now())) return 0;
      // Fake progressive data for demo
      return (habits.length * (0.3 + (i * 0.1))).round().clamp(0, habits.length);
    });
  }
}