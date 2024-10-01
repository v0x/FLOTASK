
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); 
  runApp(const MainApp()); // Launches the app with MainApp as the root widget
}

// MainApp is the root of the widget tree and sets the app's theme and entry point.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        primaryColor: const Color(0xFFF8F8F8), // Set primary color to pastel white
        scaffoldBackgroundColor: const Color(0xFFF8F8F8), // Apply same pastel white to the background
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFF8F8F8), // Consistently use pastel white
        ),
      ),
      home: const BottomNav(), // Main navigation using BottomNav widget

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

// BottomNav is a stateful widget managing the bottom navigation bar.
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentPageIndex = 0; // Keeps track of the current tab index

  // Builds the layout for the scaffold with navigation and content based on selected index.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomePage(),    // Index 0: Home Page
        const TaskPage(),    // Index 1: Task Page
        const CalendarPage(),// Index 2: Calendar Page
        const PomodoroPage(),// Index 3: Pomodoro Page
        const ProgressPage(),// Index 4: Progress Page
        const UserProfile(),// Index 5: User Profile Page
      ][currentPageIndex],

      // Defines the bottom navigation bar with icons and highlights based on the selected tab.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) => setState(() => currentPageIndex = index), // Update selected page
        backgroundColor: Colors.white, 
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown.shade700, // Highlight color for the selected tab
        unselectedItemColor: Colors.brown.shade300, // Inactive tab color
        showSelectedLabels: false, // Hides labels for a cleaner look
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl_rounded, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: '',
          ),
        ],
      ),
    );
  }
}
