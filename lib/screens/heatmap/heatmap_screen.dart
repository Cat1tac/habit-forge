// lib/screens/heatmap/heatmap_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../data/database/habit_dao.dart';
import '../../providers/habit_provider.dart';
import '../../data/models/habit.dart';

/// Displays a streak heatmap calendar for any selected habit
class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final HabitDao _habitDao = HabitDao();
  Habit? _selectedHabit;
  Map<DateTime, int> _completionMap = {};
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Streak Heatmap'),
        backgroundColor: AppColors.backgroundDark,
      ),
      body: Column(
        children: [
          _buildHabitSelector(),
          if (_selectedHabit != null) ...[
            _buildCalendar(),
            _buildLegend(),
            _buildStreakStats(),
          ] else
            _buildSelectPrompt(),
        ],
      ),
    );
  }

  Widget _buildHabitSelector() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<Habit>(
            value: _selectedHabit,
            hint: const Text('Select a habit to view'),
            dropdownColor: AppColors.backgroundCard,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: provider.habits
                .map((h) => DropdownMenuItem(
                      value: h,
                      child: Text('${h.icon} ${h.name}'),
                    ))
                .toList(),
            onChanged: (habit) {
              setState(() => _selectedHabit = habit);
              if (habit != null) _loadCompletions(habit.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
        weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
        outsideTextStyle: TextStyle(color: AppColors.textMuted),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        // Custom day cell builder for heatmap coloring
        defaultBuilder: (context, day, focusedDay) {
          final key = DateTime(day.year, day.month, day.day);
          final score = _completionMap[key];

          if (score == null) return null; // Default rendering

          // Color intensity based on score
          final color = _getHeatColor(score);
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Less  ', style: TextStyle(color: AppColors.textSecondary)),
          ...List.generate(5, (i) {
            return Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _getHeatColor((i + 1) * 20),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
          const Text('  More', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStreakStats() {
    final completedDays = _completionMap.length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Total Days', '$completedDays', '📅'),
          const SizedBox(width: 12),
          _buildStatCard(
            'Avg Score',
            _completionMap.isEmpty
                ? '0'
                : '${(_completionMap.values.reduce((a, b) => a + b) / completedDays).round()}',
            '⭐',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectPrompt() {
    return const Expanded(
      child: Center(
        child: Text(
          'Select a habit above\nto view its heatmap 📅',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ),
    );
  }

  /// Returns a green with opacity based on completion score 0-150
  Color _getHeatColor(int score) {
    final intensity = (score / 150).clamp(0.0, 1.0);
    return Color.lerp(
      AppColors.success.withOpacity(0.2),
      AppColors.success,
      intensity,
    )!;
  }

  Future<void> _loadCompletions(String habitId) async {
    final map = await _habitDao.getCompletionMap(habitId);
    setState(() => _completionMap = map);
  }
}