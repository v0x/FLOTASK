import 'package:flutter/material.dart';
import 'add_task.dart'; // Import add_task.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'task.dart';

// Stateful widget for AddGoalPage
class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

// State class for AddGoalPage
class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _titleController =
      TextEditingController(); // Controller for goal title
  final List<Map<String, dynamic>> _tasks = []; // Change type to store map data

  //final List<String> _tasks = []; // Local list to store tasks temporarily
  bool _isGoalComplete = false;
  final TextEditingController _categoryController =
      TextEditingController(); //controller for Category
  final TextEditingController _noteController =
      TextEditingController(); //controller for Note

  DateTime? _startDate; //variable to store start date
  DateTime? _endDate; //variable to store end date

  // Method to check if both goal name and tasks are provided
  void _checkIfGoalIsComplete() {
    setState(() {
      _isGoalComplete = _titleController.text.isNotEmpty && _tasks.isNotEmpty;
    });
  }

  //function to show date picker and allow user to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      ValueChanged<DateTime?> onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          initialDate ?? DateTime.now(), //set initial date to current if null
      firstDate: DateTime(2000), //set first selectable date
      lastDate: DateTime(2101), //set last selectable date
    );
    //if user selected a date and it is different from the current date
    if (pickedDate != null && pickedDate != initialDate) {
      onDateSelected(pickedDate); //update the selected date
    }
  }

  // Save goal and tasks to Firestore
  Future<void> _saveGoal() async {
    final goalTitle = _titleController.text;

    if (goalTitle.isNotEmpty && _tasks.isNotEmpty) {
      // Create a reference for the new goal
      final goalRef = FirebaseFirestore.instance.collection('goals').doc();

      // Save goal to Firestore
      await goalRef.set({
        'title': goalTitle,
        'category': _categoryController.text, // Goal category
        'note': _noteController.text, // Goal note
        'startDate': _startDate != null
            ? Timestamp.fromDate(_startDate!)
            : null, // Start date
        'endDate':
            _endDate != null ? Timestamp.fromDate(_endDate!) : null, // End date
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save tasks to Firestore under the goal
      for (final taskData in _tasks) {
        await goalRef.collection('tasks').add({
          'task': taskData['task'], // Task name returned from add_task.dart
          //'repeatInterval': _repeatIntervalNotifier.value, // From add_task.dart
          'repeatInterval': taskData['repeatInterval'],
          'startDate':
              _startDate != null ? Timestamp.fromDate(_startDate!) : null,
          'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
          'selectedTime': taskData['selectedTime'], // Specific time
          'status': 'todo', // Set status as "todo" by default
        });
      }

      // Clear data after saving
      _titleController.clear();
      _tasks.clear();
      _categoryController.clear();
      _noteController.clear();
      setState(() {
        _isGoalComplete = false;
      });

      print('Goal and tasks saved to Firestore');

      // Navigate to the TaskPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaskPage()),
      );
    }
  }

  // Navigate to AddTaskPage to add tasks
  void _navigateToAddTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskPage()),
    );

    if (newTask != null) {
      setState(() {
        _tasks.add(newTask); // Add the new task to the local list
        _checkIfGoalIsComplete(); // Check if the goal is complete after adding the task
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goal'),
        backgroundColor: const Color(0xFFEBEAE3),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isGoalComplete
                ? _saveGoal
                : null, // Save goal when check icon is pressed
          ),
        ],
      ),
      backgroundColor: const Color(0xFFEBEAE3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
              ),
              onChanged: (value) => _checkIfGoalIsComplete(),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                //button to select start date
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, _startDate, (date) {
                      setState(() {
                        _startDate = date; //set selected start date
                      });
                    }),
                    child: Text(_startDate == null
                        ? 'Select Start Date' //show if no date selected
                        //: 'Start Date: ${_startDate!.toLocal()}'.split(' ')[0]),//display selected start date
                        : 'Start Date: ${_startDate!.year}-${_startDate!.month}-${_startDate!.day}'),
                  ),
                ),
                const SizedBox(
                    width: 16.0), //space between start and end date buttons
                //button to select end date
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, _endDate, (date) {
                      setState(() {
                        _endDate = date;
                      });
                    }),
                    child: Text(_endDate == null
                        ? 'Select End Date' //show if no date selected
                        //: 'End Date: ${_endDate!.toLocal()}'.split(' ')[0]),
                        : 'End Date: ${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'), // Properly formatted date
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Category text field
            TextField(
              controller: _categoryController, //controller for the category
              decoration: const InputDecoration(
                labelText: 'Category',
                //border: OutlineInputBorder(),
              ),
              keyboardType:
                  TextInputType.visiblePassword, // Example to avoid emoji
            ),

            const SizedBox(height: 8.0),
            // Note text field
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                //border: OutlineInputBorder(),
              ),
              //keyboardType: TextInputType.text,
              keyboardType:
                  TextInputType.visiblePassword, // Example to avoid emoji
              //maxLines: 3, // Allows for multi-line input
            ),
            const SizedBox(height: 16.0), //spacing between widgets
            const Text(
              'Tasks for this Goal', //section heading for tasks
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed:
                  _navigateToAddTask, // Navigate to AddTaskPage to add tasks
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tasks[index]['task']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
