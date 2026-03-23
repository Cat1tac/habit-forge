import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/habit_provider.dart';
import '../../providers/streak_provider.dart';
import 'widgets/habit_card.dart';
import 'widgets/daily_progress_ring.dart';

/// Main home screen — shows today's habits and overall progress
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load habits when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDailyProgress(),
            _buildHabitList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-habit'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Mission'),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Habit Mastery League',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                _getTodayGreeting(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          // AI Buddy shortcut button
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/ai-buddy'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🤖', style: TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress() {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final total = provider.todaysHabits.length;
        // Count how many habits have been completed today
        // (In full implementation, track via streak provider)
        const completed = 0;

        return DailyProgressRing(
          completed: completed,
          total: total,
        );
      },
    );
  }

  Widget _buildHabitList() {
    return Expanded(
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.habits.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.habits.length,
            itemBuilder: (context, index) {
              final habit = provider.habits[index];
              return HabitCard(
                habit: habit,
                onComplete: () => _onHabitComplete(habit.id),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/habit-detail',
                  arguments: habit,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No missions yet!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first habit mission to begin your league journey.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedNavIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedNavIndex = index);
        _navigateFromBottomNav(index);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.whatshot), label: 'Streaks'),
        NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
        NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Badges'),
      ],
    );
  }

  void _navigateFromBottomNav(int index) {
    final routes = ['/home', '/heatmap', '/dashboard', '/badges'];
    if (index != 0) Navigator.pushNamed(context, routes[index]);
  }

  void _onHabitComplete(String habitId) {
    context.read<HabitProvider>().completeHabit(habitId);
    // Show celebration snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Habit completed! +10 XP'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getTodayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, Champion! ☀️';
    if (hour < 17) return 'Keep crushing it! 💪';
    return 'Evening grind! 🌙';
  }
}