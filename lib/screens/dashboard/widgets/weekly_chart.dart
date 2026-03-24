import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';
import '../../../data/database/habit_dao.dart';

/// Bar chart showing real daily habit completion counts for the current week.
/// Each bar represents one day (Mon–Sun).
/// Data is loaded asynchronously from habit_logs via HabitDao.
class WeeklyChart extends StatefulWidget {
  final List<Habit> habits;

  const WeeklyChart({super.key, required this.habits});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  final HabitDao _habitDao = HabitDao();

  // completionsPerDay[i] = number of habits completed on weekDays[i]
  List<int> _completionsPerDay = List.filled(7, 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  @override
  void didUpdateWidget(WeeklyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if the habits list changes (e.g. new habit added)
    if (oldWidget.habits.length != widget.habits.length) {
      _loadRealData();
    }
  }

  /// Queries completion maps for all habits and aggregates by day of week.
  Future<void> _loadRealData() async {
    if (widget.habits.isEmpty) {
      setState(() {
        _completionsPerDay = List.filled(7, 0);
        _isLoading = false;
      });
      return;
    }

    final weekDays = AppDateUtils.currentWeekDays();
    final counts = List.filled(7, 0);

    // For each habit, get its full completion map and check each week day
    for (final habit in widget.habits) {
      final completionMap = await _habitDao.getCompletionMap(habit.id);

      for (int i = 0; i < weekDays.length; i++) {
        final key = AppDateUtils.toDateOnly(weekDays[i]);
        if (completionMap.containsKey(key)) {
          counts[i]++;
        }
      }
    }

    if (mounted) {
      setState(() {
        _completionsPerDay = counts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = AppDateUtils.currentWeekDays();
    final maxY = (widget.habits.length + 1).toDouble().clamp(2.0, double.infinity);

    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

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
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.round()} / ${widget.habits.length}',
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
                  final isToday = AppDateUtils.isToday(weekDays[idx]);
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
            final isFuture = weekDays[i].isAfter(DateTime.now());
            final count = _completionsPerDay[i].toDouble();

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: isFuture ? 0 : count,
                  color: isFuture
                      ? Colors.transparent
                      : isToday
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.55),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: !isFuture,
                    toY: widget.habits.length.toDouble(),
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
}