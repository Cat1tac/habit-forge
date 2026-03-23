# HabitForge - Campus Habit Mastery League

**Offline-first Flutter mobile app** with streaks, levels, history, and a simple on-device AI Habit Buddy.

**Team:**  
- Rahul Kadam (UI/UX, Navigation, Animations, Documentation)  
- Powell Wayne (Database, State Management, Analytics, Testing)

## Features
- 7 distinct screens (Home, Habits List, Add/Edit, Detail, Analytics)
- Full SQLite CRUD operations
- Streak tracking + history
- Local AI Habit Buddy (rule-based smart suggestions)
- Beautiful charts with fl_chart (bonus points)
- Responsive design (portrait & landscape)
- Material 3 theming + smooth animations
- 100% offline — no cloud APIs

## Screenshots
(See the Chrome screenshots you took)

## Tech Stack
- Flutter (latest stable)
- sqflite + path_provider
- Provider (state management)
- fl_chart (analytics)
- uuid, intl

## How to Run
1. `git clone https://github.com/rahulka/habitforge-mobile.git`
2. `cd habitforge-mobile`
3. `flutter pub get`
4. `flutter run -d web-server`

## APK
Download the release APK from the Releases tab (or run `flutter build apk --release`).

**This project fulfills all undergraduate requirements + bonus features (charts, AI, animations, responsive design).**

MIT License © 2026 Rahul Kadam & Powell Wayne
