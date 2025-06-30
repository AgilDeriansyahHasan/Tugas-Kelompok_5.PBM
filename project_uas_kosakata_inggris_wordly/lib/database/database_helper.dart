import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/habit.dart'; // Pastikan path ini sesuai dengan struktur folder kamu

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE habits (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            example TEXT,
            isDone INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<Habit>> getAllHabits() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('habits');

      return maps.map((map) => Habit.fromJson(map)).toList();
    } catch (e) {
      print('❌ Gagal load habits: $e');
      return [];
    }
  }

  Future<void> insertHabit(Habit habit) async {
    try {
      final db = await database;
      await db.insert(
        'habits',
        habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Gagal insert habit: $e');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      final db = await database;
      await db.update(
        'habits',
        habit.toMap(),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
    } catch (e) {
      print('❌ Gagal update habit: $e');
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      final db = await database;
      await db.delete(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Gagal delete habit: $e');
    }
  }
}
