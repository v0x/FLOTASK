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
import 'package:flotask/pages/category.dart';
import 'package:flotask/pages/pomodoroPage.dart';
import 'package:flotask/pages/dailytask.dart';
import 'package:flotask/pages/progress.dart';
import 'package:flotask/pages/achievements.dart';
import 'package:flotask/pages/map.dart';

// TEST voice memos
import 'package:flotask/components/voice_memos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Notifications notifications = Notifications();
  await notifications.initState();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MainApp());
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
            bodyLarge: TextStyle(color: Color(0xFF8D6E63)),
            bodyMedium: TextStyle(color: Color(0xFF8D6E63)),
            displayLarge: TextStyle(color: Color(0xFF8D6E63)),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white70),
            bodyMedium: TextStyle(color: Colors.white70),
            displayLarge: TextStyle(color: Colors.white),
          ),
        ),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: LoginPage(),
        routes: {
          '/home': (context) =>
              RootLayout(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
          '/signup': (context) => SignupPage(),
        },
      ),
    );
  }
}

class RootLayout extends StatefulWidget {
  final VoidCallback toggleTheme; // Function to toggle theme
  final bool isDarkMode; // Pass the theme state

  const RootLayout(
      {super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _RootLayoutState createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomePage(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
        TaskPage(),
        CalendarPage(),
        PomodoroPage(),
        ProgressPage(),
        Category(),
        AchievementPage(),
        MapPage(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task, size: 30),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 30),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm, size: 30),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl_rounded, size: 30),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin, size: 30),
            label: '',
          ),
        ],
      ),
    );
  }
}
