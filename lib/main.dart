// lib/main.dart
// Entry point for Habit Mastery League.
// Initializes services before the widget tree launches.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  // Must be called before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set the system UI overlay style (status bar appearance)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // white icons on dark bg
      systemNavigationBarColor: Color(0xFF1A1A2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local notifications (streak reminders, badge alerts)
  //await NotificationService().initialize();

  runApp(const HabitMasteryApp());
}