import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/user.dart';
import '../pages/auth.dart';
import '../pages/homepage.dart';

// Fungsi main sekarang menjadi async
Future<void> main() async {
  // Memastikan semua widget Flutter sudah diinisialisasi sebelum menjalankan aplikasi.
  WidgetsFlutterBinding.ensureInitialized();

  // Panggil metode inisialisasi database factory sebelum menjalankan aplikasi.
  // Ini adalah langkah kunci untuk cross-platform.
  await DatabaseHelper.instance.initialize();

  runApp(const MyApp());
}

/// Kelas utama aplikasi yang merupakan StatefulWidget.
/// Ini memungkinkan state aplikasi (seperti tema dan status login) untuk dikelola secara global.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Metode statis untuk mengakses state dari `MyApp` (_MyAppState).
  /// Ini berguna untuk memanggil fungsi seperti `setTheme` atau `setAuthentication`
  /// dari widget anak mana pun di dalam aplikasi.
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // State untuk menyimpan mode tema saat ini (terang, gelap, atau sistem).
  ThemeMode _themeMode = ThemeMode.system;

  // State untuk menyimpan informasi pengguna yang sedang login.
  // Jika null, berarti tidak ada pengguna yang login.
  User? _currentUser;

  /// Getter untuk memeriksa apakah pengguna sudah terautentikasi.
  bool get isAuthenticated => _currentUser != null;

  /// Fungsi untuk mengubah tema aplikasi secara global.
  /// Menerima boolean `isDark` untuk menentukan tema.
  void setTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  /// Fungsi untuk mengubah status autentikasi pengguna.
  /// Menerima `isAuthenticated` dan objek `User` (opsional).
  /// Jika logout, panggil dengan `isAuthenticated = false`.
  /// Jika login, panggil dengan `isAuthenticated = true` dan teruskan data pengguna.
  void setAuthentication(bool isAuthenticated, {User? user}) {
    setState(() {
      if (isAuthenticated) {
        _currentUser = user;
      } else {
        _currentUser = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Skema warna untuk tema terang (light theme).
    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.limeAccent,
      brightness: Brightness.light,
    );

    // Skema warna untuk tema gelap (dark theme).
    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.limeAccent,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Vocabulary Vault',
      debugShowCheckedModeBanner: false,

      // Konfigurasi tema terang
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: lightScheme.primaryContainer,
          titleTextStyle: TextStyle(
            color: lightScheme.onPrimaryContainer,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Konfigurasi tema gelap
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: darkScheme.primaryContainer,
          titleTextStyle: TextStyle(
            color: darkScheme.onPrimaryContainer,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      themeMode: _themeMode,

      // Logika utama untuk navigasi:
      // Jika pengguna sudah terautentikasi (`_currentUser` tidak null), tampilkan HomePage.
      // Jika tidak, tampilkan AuthPage untuk login atau register.
      home: isAuthenticated
          ? HomePage(user: _currentUser!)
          : const AuthPage(),
    );
  }
}