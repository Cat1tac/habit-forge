class AppStrings {
  AppStrings._(); // Prevent instantiation

  // App-wide
  static const String appName = 'Habit Mastery League';
  static const String appTagline = 'Level up your daily routine';

  // Splash Screen
  static const String splashLoading = 'Loading your league...';
  static const String splashInitDb = 'Preparing mission database...';

  // Home Screen
  static const String homeTitle = 'Habit Mastery League';
  static const String homeNoHabits = 'No missions yet!';
  static const String homeNoHabitsSubtitle =
      'Create your first habit mission to begin your league journey.';
  static const String homeNewMission = 'New Mission';
  static const String homeTodayTitle = "Today's Missions";
  static const String homeCompleteButton = 'Complete';
  static const String homeGreetingMorning = 'Good morning, Champion! ☀️';
  static const String homeGreetingAfternoon = 'Keep crushing it! 💪';
  static const String homeGreetingEvening = 'Evening grind! 🌙';
  static const String homeXpGained = '+10 XP earned!';
  static const String homeHabitCompleted = '✅ Habit completed!';

  // Create Habit Screen
  static const String createTitle = 'New Mission';
  static const String createNameLabel = 'Mission Name';
  static const String createNameHint = 'e.g. Morning Run, Read 20 Pages';
  static const String createDescLabel = 'Description (optional)';
  static const String createDescHint = 'What does success look like?';
  static const String createFrequencyLabel = 'Frequency';
  static const String createFreqDaily = 'Daily';
  static const String createFreqWeekly = 'Weekly';
  static const String createIconLabel = 'Pick an Icon';
  static const String createColorLabel = 'Pick a Color';
  static const String createSaveButton = 'Launch Mission';
  static const String createValidateName = 'Please enter a mission name';

  // Habit Detail Screen
  static const String detailLevel = 'Level';
  static const String detailXp = 'XP';
  static const String detailStreak = 'Current Streak';
  static const String detailLongest = 'Best Streak';
  static const String detailShields = 'Shields';
  static const String detailTotalLogs = 'Total Completions';
  static const String detailHistory = 'Recent History';
  static const String detailDeleteTitle = 'Delete Mission';
  static const String detailDeleteBody =
      'This will permanently delete this habit and all its history. Are you sure?';
  static const String detailDeleteConfirm = 'Delete';
  static const String detailDeleteCancel = 'Cancel';

  // Heatmap Screen
  static const String heatmapTitle = 'Streak Heatmap';
  static const String heatmapSelectHabit = 'Select a habit to view its heatmap';
  static const String heatmapDropdownHint = 'Select a habit';
  static const String heatmapTotalDays = 'Total Days';
  static const String heatmapAvgScore = 'Avg Score';
  static const String heatmapLegendLess = 'Less';
  static const String heatmapLegendMore = 'More';

  // Insight Dashboard Screen
  static const String dashTitle = 'Insight Dashboard';
  static const String dashWeeklyScore = 'Weekly Score';
  static const String dashTotalXp = 'Total XP';
  static const String dashBestStreak = 'Best Streak';
  static const String dashCompletion = 'Completion Rate';
  static const String dashTrendTitle = 'This Week\'s Activity';
  static const String dashNoData = 'Complete some habits to see your trends!';

  // Challenges Screen
  static const String challengesTitle = 'Challenges';
  static const String challengesActive = 'Active';
  static const String challengesCompleted = 'Completed';
  static const String challengesDifficulty = 'Difficulty';
  static const String challengesReward = 'Reward';
  static const String challengesNoActive = 'No active challenges right now. Check back tomorrow!';
  static const String challengesClaimButton = 'Claim Reward';
  static const String challengesCompleteLabel = '✅ Completed';

  // Adaptive Goals Screen
  static const String adaptiveTitle = 'Adaptive Goals';
  static const String adaptiveSubtitle =
      'Goals generated from your performance patterns';
  static const String adaptiveStreak = 'Streak Goal';
  static const String adaptiveCompletion = 'Completion Goal';
  static const String adaptiveXp = 'XP Goal';
  static const String adaptiveCurrentPace = 'At your current pace:';

  // Weekly Reflection Screen
  static const String reflectionTitle = 'Weekly Reflection';
  static const String reflectionMoodLabel = 'How was your week? (1–5)';
  static const String reflectionHighlightsLabel = 'Highlights 🌟';
  static const String reflectionHighlightsHint =
      'What went well this week?';
  static const String reflectionStrugglesLabel = 'Struggles 💪';
  static const String reflectionStrugglesHint =
      'What was challenging? Be honest.';
  static const String reflectionAiButton = '🤖 Get AI Insight';
  static const String reflectionSaveButton = 'Save Reflection';
  static const String reflectionSaved = 'Reflection saved! Great self-awareness.';
  static const String reflectionAiLoading = 'Generating insight...';

  // Reflection History Screen
  static const String reflectionHistoryTitle = 'Reflection History';
  static const String reflectionHistoryEmpty =
      'No reflections yet. Complete your first weekly check-in!';

  // Badges Screen
  static const String badgesTitle = 'Mission Badges';
  static const String badgesEarned = 'Earned';
  static const String badgesLocked = 'Locked';
  static const String badgesProgress = 'Progress';
  static const String badgesUnlocked = '🏅 Badge Unlocked!';

  // AI Buddy Screen
  static const String aiTitle = 'AI Habit Buddy';
  static const String aiSubtitle = 'Your personal habit intelligence coach';
  static const String aiMicroGoalSection = "Today's Micro-Goal";
  static const String aiPepSection = 'Pep Talk';
  static const String aiRefreshButton = 'Refresh';
  static const String aiLoadingGoal = 'Generating your micro-goal...';
  static const String aiLoadingPep = 'Crafting your pep talk...';
  static const String aiFallback =
      'Your buddy is recharging! Keep going anyway — you\'ve got this! 💪';

  // Errors / Validation
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorDatabase = 'Database error. Please restart the app.';
  static const String errorNetwork = 'Network unavailable. AI features require internet.';

  // Navigation labels
  static const String navHome = 'Home';
  static const String navStreaks = 'Streaks';
  static const String navInsights = 'Insights';
  static const String navBadges = 'Badges';
}