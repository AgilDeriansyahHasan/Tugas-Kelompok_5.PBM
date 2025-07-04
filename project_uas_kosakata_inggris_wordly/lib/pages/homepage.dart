// pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import '../models/user.dart';
import '../pages/progress.dart';
import '../pages/profile.dart';
import '../pages/review.dart';
import '../pages/vocabulary.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Indeks halaman yang sedang aktif.
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman dengan meneruskan data pengguna.
    _pages = [
      VocabularyPage(currentUser: widget.user),
      const ReviewPage(),
      const ProgressPage(),
      ProfilePage(user: widget.user),
    ];
  }

  // PERUBAHAN: Definisikan destinasi navigasi di satu tempat.
  // Ini akan digunakan untuk membangun BottomNavigationBar, NavigationRail, dan Drawer.
  final List<NavigationDestination> destinations = const [
    NavigationDestination(
      icon: Icon(Icons.book_outlined),
      selectedIcon: Icon(Icons.book),
      label: 'Vocabulary',
    ),
    NavigationDestination(
      icon: Icon(Icons.rate_review_outlined),
      selectedIcon: Icon(Icons.rate_review),
      label: 'Review',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Progress',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // PERUBAHAN: Ganti Scaffold dengan AdaptiveScaffold.
    return AdaptiveScaffold(
      // Indeks terpilih saat ini.
      selectedIndex: _selectedIndex,

      // Callback yang dipanggil saat pengguna memilih destinasi baru.
      onSelectedIndexChange: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      useDrawer: false,
      // Daftar destinasi navigasi yang sudah kita buat.
      destinations: destinations,

      // AppBar akan ditampilkan di layar kecil.
      // Di layar besar, judul akan ditampilkan di body.
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(destinations[_selectedIndex].label),
        // Kita pindahkan actions ke properti 'actions' di AdaptiveScaffold
        // agar bisa ditempatkan secara adaptif.
      ),

      // Properti 'actions' ini akan ditempatkan oleh AdaptiveScaffold
      // di AppBar (layar kecil) atau di pojok atas (layar besar).
      // actions: [
      //   IconButton(
      //     icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
      //     onPressed: () => MyApp.of(context).setTheme(!isDarkMode),
      //     tooltip: 'Toggle Theme',
      //   ),
      //   IconButton(
      //     icon: const Icon(Icons.logout),
      //     onPressed: () => MyApp.of(context).setAuthentication(false),
      //     tooltip: 'Logout',
      //   ),
      // ],

      // Builder untuk body utama.
      // Widget di sini akan ditampilkan di area konten utama.
      body: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _pages[_selectedIndex]),
          ],
        );
      },
    );
  }
}