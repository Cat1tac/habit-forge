import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/reflection.dart';
import '../../data/database/reflection_dao.dart';

/// Displays a list of past weekly reflection entries.
class ReflectionHistoryScreen extends StatefulWidget {
  const ReflectionHistoryScreen({super.key});

  @override
  State<ReflectionHistoryScreen> createState() =>
      _ReflectionHistoryScreenState();
}

class _ReflectionHistoryScreenState extends State<ReflectionHistoryScreen> {
  final ReflectionDao _dao = ReflectionDao();
  List<Reflection> _reflections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _dao.getAllReflections();
    if (mounted) {
      setState(() {
        _reflections = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(AppStrings.reflectionHistoryTitle,
            style: AppTextStyles.headingMedium),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reflections.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📓', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(AppStrings.reflectionHistoryEmpty,
              textAlign: TextAlign.center, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reflections.length,
      itemBuilder: (_, i) => _buildCard(_reflections[i]),
    );
  }

  Widget _buildCard(Reflection r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: mood + week range
          Row(
            children: [
              Text(r.moodEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.weekRangeDisplay, style: AppTextStyles.headingSmall),
                    Text('Mood: ${r.mood}/5', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),

          // Highlights
          if (r.highlights != null && r.highlights!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSection('🌟 Highlights', r.highlights!),
          ],

          // Struggles
          if (r.struggles != null && r.struggles!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSection('💪 Struggles', r.struggles!),
          ],

          // AI insight
          if (r.aiInsight != null && r.aiInsight!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r.aiInsight!,
                        style: AppTextStyles.aiBuddyMessage),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 4),
        Text(text, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}