// lib/app.dart

import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/challenges/adaptive_goals_screen.dart';
import 'package:habit_tracker/screens/habits/habit_detail_screen.dart';
import 'package:habit_tracker/screens/habits/habit_list_screen.dart';
import 'package:habit_tracker/screens/reflections/reflection_history_screen.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/habit_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/challenge_provider.dart';
import 'providers/ai_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/habits/create_habit_screen.dart';
import 'screens/heatmap/heatmap_screen.dart';
import 'screens/dashboard/insight_dashboard_screen.dart';
import 'screens/challenges/challenges_screen.dart';
import 'screens/reflections/weekly_reflection_screen.dart';
import 'screens/badges/badges_screen.dart';
import 'screens/ai_buddy/ai_buddy_screen.dart';
import 'core/theme/app_theme.dart';

class HabitMasteryApp extends StatelessWidget {
  const HabitMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
      ],
      child: MaterialApp(
        title: 'Habit Mastery League',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: '/splash',
        routes: {
          '/splash':              (_) => const SplashScreen(),
          '/home':                (_) => const HomeScreen(),
          '/create-habit':        (_) => const CreateHabitScreen(),
          '/habit-detail':        (_) => const HabitDetailScreen(),
          '/habit-list':          (_) => const HabitListScreen(),
          '/heatmap':             (_) => const HeatmapScreen(),
          '/dashboard':           (_) => const InsightDashboardScreen(),
          '/challenges':          (_) => const ChallengesScreen(),
          '/adaptive-goals':      (_) => const AdaptiveGoalsScreen(),
          '/reflection':          (_) => const WeeklyReflectionScreen(),
          '/reflection-history':  (_) => const ReflectionHistoryScreen(),
          '/badges':              (_) => const BadgesScreen(),
          '/ai-buddy':            (_) => const AiBuddyScreen(),
        },
      ),
    );
  }
}