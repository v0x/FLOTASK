import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flotask/pages/calendar.dart';
import 'package:flotask/pages/home.dart';
import 'package:flotask/pages/pomodoro.dart';
import 'package:flotask/pages/task.dart';
import 'package:flotask/pages/progress.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  String fontSize = await _getSavedFontSize(); // Get saved font size
  String language = await _getSavedLanguage(); // Get saved language
  runApp(MainApp(savedFontSize: fontSize, savedLanguage: language)); // Pass both to MainApp
}

// Function to get saved font size from SharedPreferences
Future<String> _getSavedFontSize() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('fontSize') ?? 'Medium'; // Default to Medium
}

// Function to get saved language from SharedPreferences
Future<String> _getSavedLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('language') ?? 'English'; // Default to English
}

class MainApp extends StatelessWidget {
  final String savedFontSize;
  final String savedLanguage;
  const MainApp({super.key, required this.savedFontSize, required this.savedLanguage});

  @override
  Widget build(BuildContext context) {
    double fontSize = _getFontSize(savedFontSize); // Apply the saved font size

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        primaryColor: const Color(0xFFF8F8F8), // Set primary color to pastel white
        scaffoldBackgroundColor: const Color(0xFFF8F8F8), // Apply same pastel white to the background
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFF8F8F8), // Consistently use pastel white
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSize),   // Replace bodyText1 with bodyLarge
          bodyMedium: TextStyle(fontSize: fontSize),  // Replace bodyText2 with bodyMedium
          titleLarge: TextStyle(fontSize: fontSize),  // Replace headline6 with titleLarge
        ),
      ),
      home: BottomNav(savedLanguage: savedLanguage), // Pass the saved language to BottomNav
    );
  }

  // Converts the string font size to an actual double value
  double _getFontSize(String fontSize) {
    switch (fontSize) {
      case 'Small':
        return 14.0;
      case 'Large':
        return 20.0;
      default:
        return 16.0;
    }
  }
}

// BottomNav is a stateful widget managing the bottom navigation bar.
class BottomNav extends StatefulWidget {
  final String savedLanguage;
  const BottomNav({super.key, required this.savedLanguage});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentPageIndex = 0; // Keeps track of the current tab index

  // Dummy translations for demo
  Map<String, Map<String, String>> translations = {
    'English': {
      'home': 'Home',
      'task': 'Task',
      'calendar': 'Calendar',
      'pomodoro': 'Pomodoro',
      'progress': 'Progress',
    },
    'Spanish': {
      'home': 'Inicio',
      'task': 'Tarea',
      'calendar': 'Calendario',
      'pomodoro': 'Pomodoro',
      'progress': 'Progreso',
    },
    'French': {
      'home': 'Accueil',
      'task': 'Tâche',
      'calendar': 'Calendrier',
      'pomodoro': 'Pomodoro',
      'progress': 'Progrès',
    },
  };

  @override
  Widget build(BuildContext context) {
    // Get the current language translations
    Map<String, String> currentTranslation = translations[widget.savedLanguage] ?? translations['English']!;

    return Scaffold(
      body: [
        HomePage(),    // Index 0: Home Page
        const TaskPage(),    // Index 1: Task Page
        const CalendarPage(),// Index 2: Calendar Page
        const PomodoroPage(),// Index 3: Pomodoro Page
        const ProgressPage(),// Index 4: Progress Page
      ][currentPageIndex],

      // Defines the bottom navigation bar with icons and highlights based on the selected tab.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) => setState(() => currentPageIndex = index), // Update selected page
        backgroundColor: Colors.white, 
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown.shade700, // Highlight color for the selected tab
        unselectedItemColor: Colors.brown.shade300, // Inactive tab color
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: currentTranslation['home'],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task, size: 30),
            label: currentTranslation['task'],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 30),
            label: currentTranslation['calendar'],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm, size: 30),
            label: currentTranslation['pomodoro'],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl_rounded, size: 30),
            label: currentTranslation['progress'],
          ),
        ],
      ),
    );
  }
}

// App Preferences Page for settings like font size and language
class AppPreferencesPage extends StatefulWidget {
  @override
  _AppPreferencesPageState createState() => _AppPreferencesPageState();
}

class _AppPreferencesPageState extends State<AppPreferencesPage> {
  String _selectedFontSize = 'Medium';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Load saved preferences when the page is initialized
  }

  // Load saved preferences for font size and language
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFontSize = prefs.getString('fontSize') ?? 'Medium'; // Default to 'Medium'
      _selectedLanguage = prefs.getString('language') ?? 'English'; // Default to 'English'
    });
  }

  // Save the selected font size
  Future<void> _saveFontSize(String fontSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', fontSize);
  }

  // Save the selected language
  Future<void> _saveLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  @override
  Widget build(BuildContext context) {
    // Apply the selected font size to the text style
    double fontSize = _getFontSize();
    return Scaffold(
      appBar: AppBar(title: Text('App Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Font Size Selection
          ListTile(
            leading: Icon(Icons.text_fields, color: Color(0xFF8D6E63)),
            title: Text('Font Size', style: TextStyle(fontSize: fontSize)),
            trailing: DropdownButton<String>(
              value: _selectedFontSize,
              items: ['Small', 'Medium', 'Large'].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFontSize = newValue!;
                  _saveFontSize(newValue); // Save the selected font size
                });
              },
            ),
          ),
          const Divider(),
          // Language Selection
          ListTile(
            leading: Icon(Icons.language, color: Color(0xFF8D6E63)),
            title: Text('App Language', style: TextStyle(fontSize: fontSize)),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: ['English', 'Spanish', 'French'].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                  _saveLanguage(newValue); // Save the selected language
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to get font size based on user selection
  double _getFontSize() {
    switch (_selectedFontSize) {
      case 'Small':
        return 14.0;
      case 'Large':
        return 20.0;
      default:
        return 16.0;
    }
  }
}
