// FLUTTER CORE PACKAGES
import 'package:flotask/models/event_model.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:calendar_view/calendar_view.dart';

// SCREENS

import 'package:flotask/pages/home.dart';
import 'package:flotask/pages/calendar.dart';
import 'package:flotask/pages/pomodoroPage.dart';
import 'package:flotask/pages/task.dart';
import 'package:flotask/pages/progress.dart';
import 'package:flotask/pages/userprofile.dart'; // Import UserProfilePage

// TEST voice memos
import 'package:flotask/components/voice_memos.dart';

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
          ProgressPage(),
          UserProfilePage(), // Add UserProfilePage as a screen
        ][currentPageIndex],
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          indicatorColor: const Color.fromARGB(255, 7, 197, 255),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_sharp),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              label: 'Pomodoro',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_rtl_rounded),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile', // Add profile icon
            ),
          ],
        ));
  }
}
