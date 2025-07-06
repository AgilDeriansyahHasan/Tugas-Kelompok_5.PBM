import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/user.dart';
import 'pages/auth.dart';
import 'pages/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initialize();
  runApp(const MyApp());
}

// Enum tema dengan 4 opsi
enum AppTheme {
  digital,
  krem,
  mint,
  forest,
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  AppTheme _appTheme = AppTheme.digital;
  User? _currentUser;
  AppTheme get appTheme => _appTheme;

  bool get isAuthenticated => _currentUser != null;

  // Warna utama berdasarkan tema
  Color get _seedColor {
    switch (_appTheme) {
      case AppTheme.krem:
        return const Color(0xFFF5DEB3); // Krem lembut
      case AppTheme.forest:
        return const Color(0xFF388E3C); // Forest Green
      case AppTheme.digital:
      default:
        return const Color(0xFF00BFFF); // Biru neon
    }
  }

  void setTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void setColorTheme(AppTheme theme) {
    setState(() {
      _appTheme = theme;
    });
  }

  void setAuthentication(bool isAuthenticated, {User? user}) {
    setState(() {
      _currentUser = isAuthenticated ? user : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Vocabulary Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: lightScheme.primary,
          foregroundColor: lightScheme.onPrimary,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: lightScheme.onPrimary),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: darkScheme.primary,
          foregroundColor: darkScheme.onPrimary,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: darkScheme.onPrimary),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: isAuthenticated ? HomePage(user: _currentUser!) : const AuthPage(),
    );
  }
}
