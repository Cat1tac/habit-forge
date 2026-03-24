import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/reflection.dart';
import '../../data/database/reflection_dao.dart';
import '../../providers/ai_provider.dart';
import '../../providers/habit_provider.dart';
import '../../data/database/habit_dao.dart';

/// Weekly reflection form — lets the user rate their week (mood 1–5),
/// write highlights and struggles, and request an AI insight.
class WeeklyReflectionScreen extends StatefulWidget {
  const WeeklyReflectionScreen({super.key});

  @override
  State<WeeklyReflectionScreen> createState() => _WeeklyReflectionScreenState();
}

class _WeeklyReflectionScreenState extends State<WeeklyReflectionScreen> {
  final _reflectionDao = ReflectionDao();
  final _highlightsController = TextEditingController();
  final _strugglesController = TextEditingController();
  final _habitDao = ReflectionDao();
  final _habitDbDao = HabitDao();

  int _mood = 3;
  bool _isSaving = false;
  bool _aiRequested = false;
  Reflection? _savedReflection;

  @override
  void dispose() {
    _highlightsController.dispose();
    _strugglesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(AppStrings.reflectionTitle, style: AppTextStyles.headingMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/reflection-history'),
            child: const Text('History',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekHeader(),
            const SizedBox(height: 24),

            // Mood section
            Text(AppStrings.reflectionMoodLabel, style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            _buildMoodPicker(),
            const SizedBox(height: 24),

            // Highlights
            Text(AppStrings.reflectionHighlightsLabel, style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            _buildTextField(_highlightsController, AppStrings.reflectionHighlightsHint),
            const SizedBox(height: 20),

            // Struggles
            Text(AppStrings.reflectionStrugglesLabel, style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            _buildTextField(_strugglesController, AppStrings.reflectionStrugglesHint),
            const SizedBox(height: 28),

            // AI Insight section
            if (_savedReflection != null) _buildAiInsightSection(),
            if (_savedReflection == null) _buildAiButton(),

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(AppStrings.reflectionSaveButton,
                        style: AppTextStyles.headingSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Week header
  Widget _buildWeekHeader() {
    final r = Reflection(); // creates one with current week dates
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Check-in', style: AppTextStyles.headingSmall),
              Text(r.weekRangeDisplay, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  // Mood emoji picker
  Widget _buildMoodPicker() {
    final moodEmojis = ['😞', '😕', '😐', '😊', '🤩'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final score = i + 1;
        final selected = _mood == score;
        return GestureDetector(
          onTap: () => setState(() => _mood = score),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(moodEmojis[i], style: const TextStyle(fontSize: 22)),
                Text('$score',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textMuted)),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Text field helper
  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // AI insight
  Widget _buildAiButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _aiRequested ? null : _requestAiInsight,
        icon: const Text('🤖', style: TextStyle(fontSize: 18)),
        label: Text(AppStrings.reflectionAiButton,
            style: const TextStyle(color: AppColors.primary)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildAiInsightSection() {
    return Consumer<AiProvider>(
      builder: (context, aiProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('AI Weekly Insight', style: AppTextStyles.headingSmall),
                ],
              ),
              const SizedBox(height: 10),
              if (aiProvider.isLoadingInsight)
                Row(
                  children: [
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Text(AppStrings.reflectionAiLoading,
                        style: AppTextStyles.bodySmall),
                  ],
                )
              else
                Text(
                  aiProvider.weeklyInsight ?? '',
                  style: AppTextStyles.aiBuddyMessage,
                ),
            ],
          ),
        );
      },
    );
  }

  // Actions
  Future<void> _requestAiInsight() async {
    setState(() => _aiRequested = true);

    // Save reflection first so we have a record to attach the insight to
    await _save(showSnack: false);

    final habits = context.read<HabitProvider>().habits;
    final totalPossible = habits.length * 7;

    // Fetch the real completion count from the database
    final completedCount = await _habitDbDao.getWeeklyCompletionCount();

    if (!mounted) return;

    await context.read<AiProvider>().fetchWeeklyInsight(
      habits: habits,
      completedCount: completedCount,   // real value from DB
      totalPossible: totalPossible,
      userMoodNote: _mood.toString(),
    );

    // Save the AI insight text back to the reflection record
    if (_savedReflection != null) {
      final insight = context.read<AiProvider>().weeklyInsight;
      if (insight != null) {
        await _reflectionDao.saveAiInsight(_savedReflection!.id, insight);
      }
    }
  }

  Future<void> _save({bool showSnack = true}) async {
    setState(() => _isSaving = true);

    final reflection = Reflection(
      mood: _mood,
      highlights: _highlightsController.text.trim().isEmpty
          ? null
          : _highlightsController.text.trim(),
      struggles: _strugglesController.text.trim().isEmpty
          ? null
          : _strugglesController.text.trim(),
    );

    await _reflectionDao.insertReflection(reflection);
    setState(() {
      _savedReflection = reflection;
      _isSaving = false;
    });

    if (showSnack && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.reflectionSaved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}