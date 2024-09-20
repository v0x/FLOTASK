// FLUTTER CORE PACKAGES
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:calendar_view/calendar_view.dart';

// SCREENS
import 'package:flotask/pages/calendar.dart';
import 'package:flotask/pages/home.dart';
import 'package:flotask/pages/pomodoro.dart';
import 'package:flotask/pages/task.dart';
import 'package:flotask/pages/progress.dart';

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
    return CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        // Your initialization for material app.
        home: RootLayout(),
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
        appBar: AppBar(
          title: Text('Submit Data to Firestore test again'),
        ),
        body: [
          HomePage(pageIndex: currentPageIndex),
          TaskPage(),
          CalendarPage(),
          PomodoroPage(),
          ProgressPage(),
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
          ],
        ));
  }
}
