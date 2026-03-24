import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/database/database_helper.dart';

/// App entry screen shown while the database initializes.
/// Displays the league logo and a loading animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  String _statusText = 'Preparing mission database...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleIn = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Initializes the database and navigates to Home when ready
  Future<void> _initializeApp() async {
    try {
      // Trigger database creation (runs onCreate if first launch)
      await DatabaseHelper().database;

      setState(() => _statusText = 'Loading your app...');

      // Minimum splash display time so the animation plays fully
      await Future.delayed(const Duration(milliseconds: 1800));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => _statusText = 'Error loading app. Please restart.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // League trophy icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.4),
                        AppColors.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 72)),
                  ),
                ),
                const SizedBox(height: 24),

                // App title
                Text(
                  'Habit Forge',
                  style: AppTextStyles.displayLarge,
                ),
                Text(
                  'APP',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 8,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 48),

                // Loading indicator
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.backgroundCard,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),

                Text(_statusText, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}