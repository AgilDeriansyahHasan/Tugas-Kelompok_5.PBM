import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import '../models/user.dart';
import '../pages/progress.dart';
import '../pages/profile.dart';
import '../pages/quiz.dart';
import '../pages/vocabulary.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  final List<NavigationDestination> destinations = const [
    NavigationDestination(
      icon: Icon(Icons.book_outlined),
      selectedIcon: Icon(Icons.book),
      label: 'Vocabulary',
    ),
    NavigationDestination(
      icon: Icon(Icons.rate_review_outlined),
      selectedIcon: Icon(Icons.rate_review),
      label: 'Quiz',
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
  void initState() {
    super.initState();
    _pages = [
      VocabularyPage(currentUser: widget.user),
      QuizPage(currentUser: widget.user),
      ProgressPage(currentUser: widget.user),
      ProfilePage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      selectedIndex: _selectedIndex,
      onSelectedIndexChange: (index) => setState(() => _selectedIndex = index),
      destinations: destinations,
      useDrawer: false,

      // APP BAR
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            destinations[_selectedIndex].label,
            key: ValueKey(_selectedIndex),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => MyApp.of(context).setTheme(!isDarkMode),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => MyApp.of(context).setAuthentication(false),
            tooltip: 'Logout',
          ),
        ],
      ),

      // BODY
      body: (context) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _pages[_selectedIndex],
        );
      },
    );
  }
}
