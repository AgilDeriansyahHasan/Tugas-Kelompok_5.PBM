// database/database_helper.dart

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user.dart';
import '../models/word.dart';

class DatabaseHelper {
  // Nama database.
  static const _databaseName = "vocabulary_app.db";
  // Versi database, untuk keperluan migrasi.
  static const _databaseVersion = 1;

  // Membuat instance tunggal (singleton) dari DatabaseHelper.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Variabel untuk menyimpan instance database.
  static Database? _database;

  Future<void> initialize() async {
    if (kIsWeb) {
      // Jika platform adalah web, gunakan factory untuk web.
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Jika platform adalah desktop, inisialisasi FFI dan gunakan factory FFI.
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Untuk Android/iOS, tidak perlu melakukan apa-apa, karena sqflite standar akan digunakan.
  }

  /// Getter untuk database.
  /// Jika `_database` belum diinisialisasi, panggil `_initDatabase`.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inisialisasi database.
  /// Menentukan path dan membuka koneksi ke database.
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate, // Fungsi yang akan dijalankan saat database dibuat pertama kali.
    );
  }

  /// Fungsi `onCreate` untuk membuat tabel-tabel yang dibutuhkan.
  Future<void> _onCreate(Database db, int version) async {
    // Perintah SQL untuk membuat tabel 'users'.
    await db.execute('''
      CREATE TABLE users (
        userId INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        imagePath TEXT
      )
    ''');

    // Perintah SQL untuk membuat tabel 'words' (sebelumnya 'habits').
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
  }

  // --- Operasi CRUD untuk User ---

  /// Memasukkan user baru. `UNIQUE` pada email akan melempar error jika email sudah ada.
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail); // Gagal jika email duplikat
  }

  /// Mengambil user berdasarkan email dan password untuk autentikasi.
  Future<User?> authenticate(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  /// Mengupdate data user.
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'userId = ?', whereArgs: [user.userId]);
  }

  // --- Operasi CRUD untuk Word (Kosakata) ---

  /// Memasukkan kata baru.
  Future<void> insertWord(Word word) async {
    final db = await database;
    await db.insert('words', word.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Mengambil semua kata milik seorang user.
  Future<List<Word>> getWords(int userId) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC', // Urutkan berdasarkan abjad.
    );
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  /// Mengupdate data sebuah kata.
  Future<void> updateWord(Word word) async {
    final db = await database;
    await db.update('words', word.toMap(), where: 'id = ?', whereArgs: [word.id]);
  }

  /// Menghapus sebuah kata berdasarkan ID-nya.
  Future<void> deleteWord(int id) async {
    final db = await database;
    await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }
}