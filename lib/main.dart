// import 'package:flutter/material.dart';
// import 'package:flotask/pages/login.dart';
// import 'package:flotask/pages/signup.dart';
// import 'package:flotask/pages/home.dart';
// import 'package:flotask/pages/calendar.dart';
// import 'package:flotask/pages/pomodoroPage.dart';
// import 'package:flotask/pages/task.dart';
// import 'package:flotask/pages/progress.dart';
// import 'package:flotask/pages/userprofile.dart';
// import 'package:flotask/models/event_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => EventProvider()),
//       ],
//       child: MaterialApp(
//         title: 'Flotask',
//         theme: ThemeData(
//           primarySwatch: Colors.yellow,
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: Color.fromARGB(255, 235, 216, 182),
//           ),
//         ),
//         debugShowCheckedModeBanner: false,
//         initialRoute: '/',
//         routes: {
//           '/': (context) => LoginPage(),
//           '/signup': (context) => SignupPage(),
//           '/home': (context) => RootLayout(),
//         },
//       ),
//     );
//   }
// }

// class RootLayout extends StatefulWidget {
//   @override
//   _RootLayoutState createState() => _RootLayoutState();
// }

// class _RootLayoutState extends State<RootLayout> {
//   int currentPageIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flotask App'),
//       ),
//       body: [
//         HomePage(pageIndex: currentPageIndex),
//         TaskPage(),
//         CalendarPage(),
//         PomodoroPage(),
//         ProgressPage(),
//         UserProfilePage(),
//       ][currentPageIndex],
//       bottomNavigationBar: NavigationBar(
//         onDestinationSelected: (int index) {
//           setState(() {
//             currentPageIndex = index;
//           });
//         },
//         selectedIndex: currentPageIndex,
//         indicatorColor: const Color.fromARGB(255, 7, 197, 255),
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.task),
//             label: 'Tasks',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.calendar_month_sharp),
//             label: 'Calendar',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.timer_outlined),
//             label: 'Pomodoro',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.checklist_rtl_rounded),
//             label: 'Progress',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:calendar_view/calendar_view.dart';

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
import 'package:flotask/pages/profile/userprofile.dart'; // User profile page
import 'package:flotask/models/event_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Notifications notifications = Notifications();
  await notifications.initState();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp()); // Launches the app with MainApp as the root widget
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF8D6E63)),
            bodyMedium: TextStyle(color: Color(0xFF8D6E63)),
            displayLarge: TextStyle(color: Color(0xFF8D6E63)),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white70),
            bodyMedium: TextStyle(color: Colors.white70),
            displayLarge: TextStyle(color: Colors.white),
          ),
        ),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/signup': (context) => SignupPage(),
          '/home': (context) => const HomePage(),
        },
        home: BottomNav(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
      ),
    );
  }
}

// BottomNav is a stateful widget managing the bottom navigation bar.
class BottomNav extends StatefulWidget {
  final VoidCallback toggleTheme; // Function to toggle theme
  final bool isDarkMode; // Pass the theme state

  const BottomNav({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentPageIndex = 0; // Keeps track of the current tab index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flotask App'),
      ),
      body: [
        HomePage(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        ), // Home page with theme toggle
        const TaskPage(),
        const CalendarPage(),
        const PomodoroPage(),
        const ProgressPage(),
        const UserProfilePage(),
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
        ],
      ),
    );
  }
}
