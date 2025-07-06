import 'dart:io';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:wordly/models/quiz_history.dart';

import '../models/user.dart';
import '../models/word.dart';
import '../models/quiz.dart'; // Pastikan QuizWord ada di file ini
import '../models/quiz_history.dart';

class DatabaseHelper {
  static const _databaseName = "vocabulary_app.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<void> initialize() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        userId INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        example TEXT,
        isDone INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        partOfSpeech TEXT,
        score INTEGER,
        totalQuestions INTEGER,
        date TEXT,
        questions TEXT,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');
  }

  // ------------------------- User CRUD -------------------------

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<User?> authenticate(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'userId = ?', whereArgs: [user.userId]);
  }

  // ------------------------- Word CRUD -------------------------

  Future<void> insertWord(Word word) async {
    final db = await database;
    await db.insert('words', word.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Word>> getWords(int userId) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  Future<void> updateWord(Word word) async {
    final db = await database;
    await db.update('words', word.toMap(), where: 'id = ?', whereArgs: [word.id]);
  }

  Future<void> deleteWord(int id) async {
    final db = await database;
    await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Word>> getWordsByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  // ------------------------- Quiz History CRUD -------------------------

  Future<void> insertQuizHistory(QuizHistory history) async {
    final db = await database;
    await db.insert('quiz_history', history.toMap());
  }

  /// Ambil semua data
  Future<List<QuizHistory>> getQuizHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('quiz_history');

    return List.generate(maps.length, (i) {
      return QuizHistory.fromMap(maps[i]);
    });
  }
}
