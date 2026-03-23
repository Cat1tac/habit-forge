import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/habit.dart';
import '../data/models/streak.dart';

/// Handles all communication with the AI API for the Habit Buddy feature.
/// Uses the Anthropic Claude API (replace with OpenAI if preferred).
class AiService {
  // IMPORTANT: Store your API key in a .env file, never commit to Git!
  // Use flutter_dotenv package for secure key management.
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = 'YOUR_API_KEY_HERE'; // Use env variable in production
  static const String _model = 'claude-3-haiku-20240307';

  // Fallback messages shown when the API is unavailable
  static const String fallbackGoal =
      "Take one small step today — every streak starts with a single completion! 🔥";

  static const String fallbackPep =
      "Your consistency is building something real. Keep showing up! 💪";

  static const String fallbackInsight =
      "Your effort this week reflects genuine commitment. Celebrate the small wins!";


  // Generate daily micro-goal for a habit
  Future<String> generateMicroGoal({
    required Habit habit,
    required Streak streak,
  }) async {
    final prompt = '''
You are a supportive, energetic habit coach for the "Habit Mastery League" app.

The user is working on this habit:
- Name: ${habit.name}
- Description: ${habit.description ?? 'No description'}
- Current Level: ${habit.level}
- Current Streak: ${streak.currentStreak} days
- Longest Streak: ${streak.longestStreak} days

Generate ONE specific, actionable micro-goal for today. 
Keep it under 2 sentences. Make it achievable in 5-15 minutes. 
Be encouraging and specific to the habit context.
''';

    return await _callApi(prompt);
  }

  // Generate a pep talk based on overall performance
  Future<String> generatePepTalk({
    required List<Habit> habits,
    required int totalStreakDays,
    required int weeklyCompletionRate,
  }) async {
    final habitSummary = habits
        .map((h) => '- ${h.name} (Level ${h.level})')
        .join('\n');

    final prompt = '''
You are an enthusiastic habit coach for the "Habit Mastery League" app.

Player stats this week:
- Active Habits:
$habitSummary
- Total Streak Days: $totalStreakDays
- Weekly Completion Rate: $weeklyCompletionRate%

Write a personalized pep talk (2-3 sentences maximum).
Reference their specific stats. Be genuine and motivating.
Avoid clichés. Match the energy level to their completion rate.
''';

    return await _callApi(prompt);
  }

  // Generate weekly insight analysis
  Future<String> generateWeeklyInsight({
    required List<Habit> habits,
    required int completedCount,
    required int totalPossible,
    required String? userMoodNote,
  }) async {
    final prompt = '''
You are a behavior analyst for the "Habit Mastery League" app.

Weekly data:
- Habits tracked: ${habits.length}
- Completed: $completedCount / $totalPossible sessions
- Completion rate: ${((completedCount / totalPossible) * 100).round()}%
- User mood note: ${userMoodNote ?? 'Not provided'}

Provide a 3-sentence insight:
1. What the data pattern suggests about their consistency
2. One specific strength to celebrate
3. One gentle suggestion for next week

Be analytical but warm. No bullet points in your response.
''';

    return await _callApi(prompt);
  }

  // Core API call
  Future<String> _callApi(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 200,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        return 'Your habit buddy is taking a break! Keep going anyway! 💪';
      }
    } catch (e) {
      // Graceful fallback if API is unavailable
      return 'Connection issue — but your streak is intact! Keep pushing! 🔥';
    }
  }
}