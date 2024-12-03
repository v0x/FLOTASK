// FLUTTER CORE PACKAGES
import 'package:flotask/models/event_model.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/providers/achievement_provider.dart';

// COMPONENTS
import 'package:flotask/components/notifications.dart';

// SCREENS
import 'package:flotask/pages/login.dart';
import 'package:flotask/pages/signup.dart';
import 'package:flotask/pages/home.dart';
import 'package:flotask/pages/calendar.dart';
import 'package:flotask/pages/pomodoroPage.dart';
import 'package:flotask/pages/task.dart';
import 'package:flotask/pages/progress.dart';
import 'package:flotask/pages/profile/userprofile.dart'; // Import UserProfilePage
import 'package:flotask/pages/achievements.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Notifications notifications = Notifications();
  await notifications.initState();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp()); // Launches the app with MainApp as the root widget
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isDarkMode = false; // Track whether dark mode is enabled

  // Function to toggle the theme
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EventProvider()),
        ChangeNotifierProvider(create: (context) => AchievementProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                  color: Color(0xFF8D6E63)), // Set color for normal text
              bodyMedium: TextStyle(
                  color: Color(0xFF8D6E63)), // Set color for smaller text
              displayLarge: TextStyle(
                  color: Color(0xFF8D6E63)), // Set color for large headings
              // Customize other text styles as needed
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: TextTheme(
              bodyLarge:
                  TextStyle(color: Colors.white70), // Set color for normal text
              bodyMedium: TextStyle(
                  color: Colors.white70), // Set color for smaller text
              displayLarge: TextStyle(
                  color: Colors.white), // Set color for large headings
              // Customize other text styles as needed
            ),
          ),
          themeMode: _isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light, // Conditionally apply the theme
          //home: BottomNav(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),

          //set the initial page to LoginPage
          home: LoginPage(),
          routes: {
            '/home': (context) =>
                BottomNav(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
            '/signup': (context) => SignupPage(), //signup page
          }),
    );
  }
}

// BottomNav is a stateful widget managing the bottom navigation bar.
class BottomNav extends StatefulWidget {
  final VoidCallback toggleTheme; // Function to toggle theme
  final bool isDarkMode; // Pass the theme state

  const BottomNav(
      {super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentPageIndex = 0; // Keeps track of the current tab index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomePage(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode), // Home page with theme toggle
        TaskPage(),
        CalendarPage(),
        PomodoroPage(),
        ProgressPage(),
        UserProfilePage(),
        AchievementPage(),
      ][currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) => setState(() => currentPageIndex = index),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown.shade700,
        unselectedItemColor: Colors.brown.shade300,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.task, size: 30), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.alarm, size: 30), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rtl_rounded, size: 30), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events, size: 30), label: ''),
        ],
      ),
    );
  }
}
