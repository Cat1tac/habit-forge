import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  //Initialize Database
  Future<Database> get database async {
    if (_database != null) return _database!; 
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit_mastery.db');

    return await openDatabase(
      path, version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  //Create all tables
  Future<void> _onCreate(Database db, int version) async {
    //Habits table - stores user habit missions
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color TEXT,
        frequency TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        xp INTEGER DEFAULT 0,
        streak_shields INTEGER DEFAULT 3,
        created_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    //Habit logs - records each completion
    await db.execute('''
      CREATE TABLE habit_logs (
        id TEXT PPRIMARY KEY,
        habit_id TEXT NOT NULL,
        completed_date TEXT NOT NULL,
        score INTEGER DEFAULT 100,
        notes TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id)
      )
    ''');

    //Streaks - tracks consecutive completion chains
    await db.execute('''
      CREATE TABLE streaks (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_completed TEXT,
        shields_used INTEGER DEFAULT 0,
        FOREIGN KEY (habit_id) REFERENCES habits (id)
      )
  ''');

    //Badges - milestone achivements
    await db.execute('''
      CREATE TABLE badges (
        id TEXT PRIMARY KEY,
        habit_id TEXT,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        condition_type TEXT,
        condition_value INTEGER,
        earned_at TEXT,
        is_earned INTEGER DEFAULT 0
      )
''');

    //Challenges - adaptive goals
    await db.execute('''
      CREATE TABLE challenges (
        id TEXT PRIMARY KEY, 
        title TEXT NOT NULL,
        description TEXT,
        target_value INTEGER,
        current_value INTEGER DEFAULT 0,
        challenge_type TEXT,
        difficulty TEXT,
        start_date TEXT,
        end_date TEXT,
        is_completed INTEGER DEFAULT 0,
        reward_xp INTEGER DEFAULT 50
      )
''');

    // Weekly reflections
    await db.execute('''
      CREATE TABLE reflections (
        id TEXT PRIMARY KEY,
        week_start TEXT NOT NULL,
        week_end TEXT NOT NULL,
        mood INTEGER,                  -- 1-5 rating
        highlights TEXT,
        struggles TEXT,
        ai_insight TEXT,               -- AI-generated analysis
        total_score INTEGER DEFAULT 0,
        habits_completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed default badges
    await _seedDefaultBadges(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
  }

  // Seed default badge definitions
  Future<void> _seedDefaultBadges(Database db) async {
    final defaultBadges = [
      {
        'id': 'badge_streak_7',
        'name': '7-Day Warrior',
        'description': 'Complete a habit 7 days in a row',
        'icon': '🔥',
        'condition_type': 'streak',
        'condition_value': 7,
        'is_earned': 0,
      },
      {
        'id': 'badge_streak_30',
        'name': 'Month Master',
        'description': 'Maintain a 30-day streak',
        'icon': '⚡',
        'condition_type': 'streak',
        'condition_value': 30,
        'is_earned': 0,
      },
      {
        'id': 'badge_level_5',
        'name': 'Habit Veteran',
        'description': 'Reach Level 5 with any habit',
        'icon': '🌟',
        'condition_type': 'level',
        'condition_value': 5,
        'is_earned': 0,
      },
      {
        'id': 'badge_completions_100',
        'name': 'Centurion',
        'description': 'Log 100 total habit completions',
        'icon': '🏆',
        'condition_type': 'completion_count',
        'condition_value': 100,
        'is_earned': 0,
      },
    ];

    for (final badge in defaultBadges) {
      await db.insert('badges', badge,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}