import 'package:flutter/material.dart';
import 'package:flotask/pages/login.dart';
import 'package:flotask/pages/signup.dart';
import 'package:flotask/pages/home.dart';
import 'package:flotask/pages/calendar.dart';
import 'package:flotask/pages/pomodoroPage.dart';
import 'package:flotask/pages/task.dart';
import 'package:flotask/pages/progress.dart';
import 'package:flotask/pages/userprofile.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'Flotask',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 235, 216, 182),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/signup': (context) => SignupPage(),
          '/home': (context) => RootLayout(),
        },
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
        title: Text('Flotask App'),
      ),
      body: [
        HomePage(pageIndex: currentPageIndex),
        TaskPage(),
        CalendarPage(),
        PomodoroPage(),
        ProgressPage(),
        UserProfilePage(),
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
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
