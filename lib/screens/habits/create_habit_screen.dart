import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../providers/streak_provider.dart';

/// Form screen for creating a new habit mission.
/// Includes name, description, frequency, icon picker, and color picker.
class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedFrequency = 'daily';
  String _selectedIcon = '⭐';
  String _selectedColor = '#6C63FF';
  bool _isSaving = false;

  // Available icons for the picker
  static const _icons = [
    '⭐', '🏃', '📚', '💪', '🧘', '🥗', '💧', '🎨',
    '🎵', '🌱', '😴', '🧹', '📝', '💻', '🏋️', '🚴',
    '🧠', '❤️', '🎯', '🌟', '🔥', '⚡', '🛡️', '🏆',
  ];

  // Available theme colors
  static const _colors = [
    '#6C63FF', '#FF6584', '#4CAF50', '#2196F3',
    '#FF9800', '#9C27B0', '#00BCD4', '#F44336',
    '#FFD700', '#E91E63', '#00E676', '#FF5722',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(AppStrings.createTitle, style: AppTextStyles.headingMedium),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Preview card
            _buildPreviewCard(),
            const SizedBox(height: 24),

            // Mission name
            _buildLabel(AppStrings.createNameLabel),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(AppStrings.createNameHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? AppStrings.createValidateName : null,
              onChanged: (_) => setState(() {}), // Refresh preview
            ),
            const SizedBox(height: 16),

            // Description
            _buildLabel(AppStrings.createDescLabel),
            TextFormField(
              controller: _descController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(AppStrings.createDescHint),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Frequency picker
            _buildLabel(AppStrings.createFrequencyLabel),
            _buildFrequencyPicker(),
            const SizedBox(height: 20),

            // Icon picker
            _buildLabel(AppStrings.createIconLabel),
            _buildIconPicker(),
            const SizedBox(height: 20),

            // Color picker
            _buildLabel(AppStrings.createColorLabel),
            _buildColorPicker(),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppStrings.createSaveButton,
                      style: AppTextStyles.headingSmall),
            ),
          ],
        ),
      ),
    );
  }

  // Preview card — live-updates as user types
  Widget _buildPreviewCard() {
    final color = _hexToColor(_selectedColor);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_selectedIcon,
                  style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty
                      ? 'Mission Name'
                      : _nameController.text,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: _nameController.text.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('LVL 1', style: AppTextStyles.levelBadge),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Frequency toggle buttons
  Widget _buildFrequencyPicker() {
    return Row(
      children: ['daily', 'weekly'].map((freq) {
        final selected = _selectedFrequency == freq;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedFrequency = freq),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: freq == 'daily' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                freq == 'daily' ? AppStrings.createFreqDaily : AppStrings.createFreqWeekly,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Icon grid picker
  Widget _buildIconPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _icons.map((icon) {
        final selected = _selectedIcon == icon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Color dot picker
  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colors.map((hex) {
        final selected = _selectedColor == hex;
        final color = _hexToColor(hex);
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2)
                    ]
                  : [],
            ),
            child: selected
                ? const Icon(Icons.check,
                    color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  // Save
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final habit = Habit(
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      frequency: _selectedFrequency,
    );

    await context.read<HabitProvider>().createHabit(habit);

    // Create a default streak record for the new habit
    await context.read<StreakProvider>().initStreakForHabit(habit.id);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  // Helpers
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.headingSmall),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
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
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}