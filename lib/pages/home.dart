import 'package:flutter/material.dart';
import 'package:flotask/components/menu.dart';
import 'package:intl/intl.dart'; // For date formatting

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current date
    final String formattedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    void _showAddTaskDialog() {
      final TextEditingController _taskController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add New Task'),
            content: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Enter task description',
                filled: true,
                fillColor: Colors.grey[200], // Light grey background for the text box
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final task = _taskController.text;
                  if (task.isNotEmpty) {
                    // You can add logic to handle the task here
                    print('Task added: $task');
                    Navigator.pop(context); // Close the dialog
                  }
                },
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.blue), // Set text color to blue
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue), // Set text color to blue
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      drawer: Menu(),
      appBar: AppBar(
        title: Text(
          'Welcome Back, John!',
          style: TextStyle(color: Colors.blue), // Set title text color to blue
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add your notification logic here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: 'Add Task',
      ),
    );
  }
}
