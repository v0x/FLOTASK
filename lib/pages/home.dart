import 'package:flutter/material.dart';
import 'package:flotask/components/menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Controls the Drawer
  String _currentMessage = ''; // Holds the time-based greeting message

  @override
  void initState() {
    super.initState();

    // Initialize animation for a floating effect on the greeting message
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial greeting based on time of day
    _currentMessage = _getTimeBasedGreeting();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose animation controller to free resources
    super.dispose();
  }

  // Get greeting message based on the current time of day
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning!';
    if (hour >= 12 && hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Menu(), // Side menu using the Menu widget
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Flat, clean AppBar with no shadow
        leading: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black.withOpacity(0.9), size: 32), 
          onPressed: () => _scaffoldKey.currentState?.openDrawer(), // Opens the Drawer via GlobalKey
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded, size: 36, color: Colors.black.withOpacity(0.7)),
            onPressed: () => print('Profile clicked'), // Placeholder for profile functionality
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Adds space above the greeting card
            SlideTransition(
              position: _slideAnimation, // Applies the floating effect to the message card
              child: _buildMessageCard(_currentMessage),
            ),
            const SizedBox(height: 20),
            // Add other components like a task list here
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: _showAddTaskDialog, // Opens a dialog to add a new task
          child: const Icon(Icons.add, size: 36), // Large add icon for a clear call to action
          backgroundColor: const Color(0xFFD2B48C), // Light brown/beige color
          tooltip: 'Add Task',
          elevation: 10, // Creates a floating effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Circular, bubbly appearance
          ),
        ),
      ),
    );
  }

  // Builds the greeting message card with a floating effect
  Widget _buildMessageCard(String message) {
    return Container(
      width: 200, // Defines a fixed width for the message card
      padding: const EdgeInsets.all(12.0), // Adjust padding for a more compact design
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E7).withOpacity(0.8), // Soft peach color with transparency
        borderRadius: BorderRadius.circular(20), // Rounded corners for a softer look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3), // Creates a subtle floating shadow
          ),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18, // Compact font size
          color: Colors.black.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Opens a dialog to add a new task
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
                  print('Task added: $task'); // Placeholder for task addition logic
                  Navigator.pop(context); // Closes the dialog
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.black.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Closes the dialog without adding a task
              child: Text('Cancel', style: TextStyle(color: Colors.black.withOpacity(0.7))),
            ),
          ],
        );
      },
    );
  }
}
