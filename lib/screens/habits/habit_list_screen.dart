// lib/screens/habits/habit_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_provider.dart';

/// Shows all habits with filter tabs (All / Daily / Weekly) and
/// supports swipe-to-archive.
class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text('All Missions', style: AppTextStyles.headingMedium),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
          ],
        ),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.habits),
              _buildList(
                  provider.habits.where((h) => h.frequency == 'daily').toList()),
              _buildList(provider.habits
                  .where((h) => h.frequency == 'weekly')
                  .toList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-habit'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<Habit> habits) {
    if (habits.isEmpty) {
      return Center(
        child: Text('No habits here yet!',
            style: AppTextStyles.bodyLarge),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, i) {
        final habit = habits[i];
        return Dismissible(
          key: Key(habit.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.archive_outlined, color: AppColors.warning),
          ),
          confirmDismiss: (_) async {
            return await _confirmArchive(context, habit);
          },
          onDismissed: (_) {
            context.read<HabitProvider>().archiveHabit(habit.id);
          },
          child: Card(
            color: AppColors.backgroundCard,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Text(habit.icon,
                  style: const TextStyle(fontSize: 28)),
              title: Text(habit.name, style: AppTextStyles.headingSmall),
              subtitle: Text('Level ${habit.level} • ${habit.frequency}',
                  style: AppTextStyles.bodySmall),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: () => Navigator.pushNamed(context, '/habit-detail',
                  arguments: habit),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmArchive(BuildContext context, Habit habit) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text('Archive ${habit.name}?',
            style: AppTextStyles.headingSmall),
        content: Text(
            'This will hide the habit but keep its history.',
            style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Archive',
                  style: TextStyle(color: AppColors.warning))),
        ],
      ),
    );
    return result ?? false;
  }
}