import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'firebase_options.dart';
import 'package:flotask/pages/calendar.dart';
import 'package:flotask/pages/home.dart';
import 'package:flotask/pages/pomodoro.dart';
import 'package:flotask/pages/task.dart';
import 'package:flotask/pages/progress.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        primaryColor: const Color(0xFFF8F8F8), // Set primary color to pastel white
        scaffoldBackgroundColor: const Color(0xFFF8F8F8), // Apply same pastel white to the background
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BottomNav(),
    );
  }
}

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentPageIndex = 0; // Keeps track of the current tab index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomePage(),        // Index 0: Home Page
        const TaskPage(),  // Index 1: Task Page
        const CalendarPage(), // Index 2: Calendar Page
        const PomodoroPage(), // Index 3: Pomodoro Page
        const ProgressPage(), // Index 4: Progress Page
        NotificationSettingsPage(), // Index 5: Notification Settings Page
      ][currentPageIndex],

      // Defines the bottom navigation bar with icons and highlights based on the selected tab.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) => setState(() => currentPageIndex = index), // Update selected page
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown.shade700, // Highlight color for the selected tab
        unselectedItemColor: Colors.brown.shade300, // Inactive tab color
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
            icon: Icon(Icons.notifications, size: 30),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Notification Settings Page with Custom Toggle
class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = false; // Tracks the toggle state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        backgroundColor: Colors.brown.shade700, // Matches the app's theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700, // Matches the app's theme
              ),
            ),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: Colors.brown.shade700, // Switch knob color
              activeTrackColor: Colors.brown.shade300, // Track color
              inactiveThumbColor: Colors.grey, // Knob color when disabled
              inactiveTrackColor: Colors.grey.shade300, // Track color when disabled
            ),
          ],
        ),
      ),
    );
  }
}

// App Preferences Page with Send Feedback and Report Issue
class AppPreferencesPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Function to save feedback or issue to Firestore
  Future<void> _saveToFirestore(BuildContext context, String type) async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a message.')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'email': email,
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$type submitted successfully!')));
      _emailController.clear();
      _messageController.clear();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit $type. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Send Feedback option
          ListTile(
            leading: Icon(Icons.feedback_outlined, color: Color(0xFF8D6E63)),
            title: Text('Send Feedback'),
            onTap: () => _showForm(context, 'Feedback'),
          ),
          const Divider(),

          // Report Issue option
          ListTile(
            leading: Icon(Icons.bug_report_outlined, color: Color(0xFF8D6E63)),
            title: Text('Report Issue'),
            onTap: () => _showForm(context, 'Issue'),
          ),
        ],
      ),
    );
  }

  // Function to show form for feedback or reporting an issue
  void _showForm(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit $type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Your Email (optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Your $type'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _emailController.clear();
                _messageController.clear();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8D6E63)),
              onPressed: () => _saveToFirestore(context, type),
            ),
          ],
        );
      },
    );
  }
}
