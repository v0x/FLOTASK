import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flotask/components/menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Controls the Drawer

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
      body: Stack(
        children: [
          // Animated sky background
          RiveAnimation.asset(
            'assets/cloud.riv', // Path to the Rive file
            fit: BoxFit.cover, // Ensures it covers the entire screen
          ),
          // Main content overlayed on the background (currently left empty)
        ],
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
