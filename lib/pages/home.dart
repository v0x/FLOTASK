import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flotask/components/menu.dart';
import 'package:intl/intl.dart'; // For DateTime formatting

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFA7C7E7), // Pastel blue sky color
        scaffoldBackgroundColor: Color(0xFFA7C7E7), // Pastel blue for the background
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black.withOpacity(0.7)), // Slightly transparent text
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Timer _timer;

  // Create a GlobalKey to control the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of dynamic messages
  final List<String> _dynamicMessages = [
    'How are you today?',
    'Stay focused!',
    'Keep going!',
    'Almost done!',
    'You got this!',
  ];

  // List of pastel colors
  final List<Color> _pastelColors = [
    Color(0xFFFFF9C4), // Light yellow
    Color(0xFFFFCCBC), // Light peach
    Color(0xFFB2EBF2), // Light cyan
    Color(0xFFC8E6C9), // Light green
    Color(0xFFD1C4E9), // Light purple
  ];

  String _currentMessage = ''; 
  Color _currentColor = Color(0xFFFFF9C4); // Initial color (light yellow)
  bool _greetingShown = false; // Track if greeting message is already shown

  @override
  void initState() {
    super.initState();

    // Initialize animation for floating effect
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset(0, -0.1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial greeting based on time of day
    _currentMessage = _getTimeBasedGreeting();

    // Timer to switch between messages every 5 seconds and change color
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        if (_greetingShown) {
          // Change message and color
          _currentMessage = _dynamicMessages[timer.tick % _dynamicMessages.length];
          _currentColor = _pastelColors[timer.tick % _pastelColors.length];
        } else {
          _greetingShown = true; // Greeting message has been shown
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel(); // Cancel timer when the widget is disposed
    super.dispose();
  }

  // Get greeting message based on current time
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning!';
    if (hour >= 12 && hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Use the key to control the Scaffold
      drawer: Menu(), // Drawer with menu items
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black.withOpacity(0.9), size: 36), // Larger and bolder dotted menu icon
          onPressed: () => _scaffoldKey.currentState?.openDrawer(), // Use the GlobalKey to open the drawer
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded, size: 40, color: Colors.black.withOpacity(0.7)), // Modern profile icon
            onPressed: () => print('Profile clicked'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            SlideTransition(
              position: _slideAnimation, // Floating effect for greeting/message
              child: _buildMessageCard(_currentMessage, _currentColor),
            ),
            SizedBox(height: 20),
            // Add other components here (e.g., task list)
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20), // Move FloatingActionButton up by 20 pixels
        child: FloatingActionButton(
          onPressed: _showAddTaskDialog, // Add new task
          child: Icon(Icons.add, size: 36), // Larger, more bubbly icon
          backgroundColor: Color(0xFFD2B48C), // Light brown/beige color
          tooltip: 'Add Task',
          elevation: 10, // Add some elevation to give a floating, bubbly effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // More circular shape for a bubbly appearance
          ),
        ),
      ),
    );
  }

  // Build message card with floating effect and dynamic color
  Widget _buildMessageCard(String message, Color color) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8), // Dynamic background color
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 10,
            offset: Offset(0, 3), // Floating shadow effect
          ),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w600),
      ),
    );
  }

  // Dialog to add new task
  void _showAddTaskDialog() {
    final TextEditingController _taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: Colors.white.withOpacity(0.9),
          title: Text('Add New Task', style: TextStyle(color: Colors.black.withOpacity(0.7))),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(
              hintText: 'Enter task description',
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final task = _taskController.text;
                if (task.isNotEmpty) {
                  print('Task added: $task');
                  Navigator.pop(context); // Close the dialog after adding task
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.black.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.black.withOpacity(0.7))),
            ),
          ],
        );
      },
    );
  }
}
