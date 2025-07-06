import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quiz_history.dart';
import '../models/quiz.dart'; // Make sure QuizWord is accessible

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'quiz_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quiz_histories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        score INTEGER,
        totalQuestions INTEGER,
        date TEXT,
        level INTEGER,
        partOfSpeech TEXT,
        questions TEXT -- Store JSON string of QuizWord list
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // This is where you would handle schema changes in future versions
    // For now, we'll keep it simple. If you add new columns, you'd do it here.
    if (oldVersion < 2) {
      // Example: If you were to add a new column in a future version
      // await db.execute("ALTER TABLE quiz_histories ADD COLUMN newColumn TEXT;");
    }
  }

  /// Inserts a new quiz history into the database.
  Future<int> insertQuizHistory(QuizHistory history) async {
    final db = await database;
    return await db.insert(
      'quiz_histories',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all quiz histories for a specific user from the database.
  Future<List<QuizHistory>> getQuizHistories(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quiz_histories',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC', // Order by most recent first
    );

    return List.generate(maps.length, (i) {
      return QuizHistory.fromMap(maps[i]);
    });
  }

  /// Deletes a specific quiz history by its ID.
  Future<int> deleteQuizHistory(int id) async {
    final db = await database;
    return await db.delete(
      'quiz_histories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all quiz histories for a specific user.
  Future<int> deleteAllQuizHistoriesForUser(int userId) async {
    final db = await database;
    return await db.delete(
      'quiz_histories',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}