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
// import 'package:flotask/components/notifications.dart';

// SCREENS
import 'package:flotask/pages/home.dart';
import 'package:flotask/pages/calendar.dart';
import 'package:flotask/pages/pomodoroPage.dart';
import 'package:flotask/pages/events.dart';
import 'package:flotask/pages/userprofile.dart';
import 'package:flotask/components/voice_memos.dart';
import 'package:flotask/pages/achievements.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EventProvider()),
        ChangeNotifierProvider(create: (context) => AchievementProvider()),
      ],
      child: MaterialApp(
        home: RootLayout(),
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromARGB(255, 235, 216, 182))),
      ),
    );
  }
}

class RootLayout extends StatefulWidget {
  @override
  _RootLayoutState createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomePage(pageIndex: currentPageIndex),
        TaskPage(),
        CalendarPage(),
        PomodoroPage(),
        UserProfilePage(), // Add UserProfilePage as a screen
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
              icon: Icon(Icons.folder, size: 30), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events, size: 30), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_pin, size: 30), label: ''),
        ],
      ),
    );
  }
}
