import 'package:flutter/material.dart';
import 'add_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _titleController =
      TextEditingController(); // Controller for goal title
  final List<Map<String, dynamic>> _tasks = []; // Change type to store map data

  bool _isGoalComplete = false;
  final TextEditingController _categoryController =
      TextEditingController(); //controller for Category
  final TextEditingController _noteController =
      TextEditingController(); //controller for Note

  DateTime? _startDate; //variable to store start date
  DateTime? _endDate; //variable to store end date

  void _checkIfGoalIsComplete() {
    setState(() {
      _isGoalComplete = _titleController.text.isNotEmpty && _tasks.isNotEmpty;
    });
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      ValueChanged<DateTime?> onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != initialDate) {
      onDateSelected(pickedDate);
    }
  }

  List<DateTime> _generateRecurringDates(
      DateTime startDate, DateTime endDate, int interval) {
    List<DateTime> recurringDates = [];
    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(Duration(days: interval))) {
      recurringDates.add(date);
    }
    return recurringDates;
  }

  Future<void> _saveGoal() async {
    final goalTitle = _titleController.text;

    // Get the current user's UID
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to log in to save a goal.')),
      );
      return;
    }

    final String userId = currentUser.uid;

    if (goalTitle.isNotEmpty && _tasks.isNotEmpty) {
      //final goalRef = FirebaseFirestore.instance.collection('goals').doc();
      final goalRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(); //store new goal under user

      int totalTaskRecurrences = 0; //store the sum of all task recurrences

      await goalRef.set({
        'title': goalTitle,
        'category': _categoryController.text,
        'note': _noteController.text,
        'startDate':
            _startDate != null ? Timestamp.fromDate(_startDate!) : null,
        'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'totalTaskCompletedRecurrences': 0,
      });

      for (final taskData in _tasks) {
        if (taskData['startDate'] != null &&
            taskData['endDate'] != null &&
            taskData['repeatInterval'] != null) {
          List<DateTime> recurrences = _generateRecurringDates(
            taskData['startDate'],
            taskData['endDate'],
            taskData['repeatInterval'],
          );

          final taskRef = await goalRef.collection('tasks').add({
            'task': taskData['task'],
            'repeatInterval': taskData['repeatInterval'],
            'startDate': Timestamp.fromDate(taskData['startDate']),
            'endDate': Timestamp.fromDate(taskData['endDate']),
            'selectedTime': taskData['selectedTime'],
            'status': 'todo',
            'totalRecurrences': recurrences.length,
            'totalCompletedRecurrences': 0,
          });
          totalTaskRecurrences += recurrences.length;

          for (DateTime date in recurrences) {
            await taskRef.collection('recurrences').add({
              'date': Timestamp.fromDate(date),
              'status': 'todo',
            });
          }
        }
      }

      // Update the goal with the totalTaskRecurrences after all tasks are added
      await goalRef.update({
        'totalTaskRecurrences': totalTaskRecurrences,
      });

      // Clear data after saving
      _titleController.clear();
      _tasks.clear();
      _categoryController.clear();
      _noteController.clear();
      setState(() {
        _isGoalComplete = false;
      });

      print('Goal and tasks saved to Firestore');

      //navigate to the Daily task view
      Navigator.of(context).pop();
    }
  }

  void _navigateToAddTask() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select start and end dates for the goal.')),
      );
      return;
    }

    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(
          goalStartDate: _startDate!,
          goalEndDate: _endDate!,
        ),
      ),
    );

    if (newTask != null) {
      setState(() {
        _tasks.add(newTask);
        _checkIfGoalIsComplete();
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
            onPressed: _isGoalComplete ? _saveGoal : null,
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
              decoration: const InputDecoration(labelText: 'Goal Title'),
              onChanged: (value) => _checkIfGoalIsComplete(),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, _startDate, (date) {
                      setState(() {
                        _startDate = date;
                      });
                    }),
                    child: Text(_startDate == null
                        ? 'Select Start Date'
                        : 'Start Date: ${_startDate!.year}-${_startDate!.month}-${_startDate!.day}'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, _endDate, (date) {
                      setState(() {
                        _endDate = date;
                      });
                    }),
                    child: Text(_endDate == null
                        ? 'Select End Date'
                        : 'End Date: ${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Tasks for this Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _navigateToAddTask,
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  String startDate = _tasks[index]['startDate'] != null
                      ? '${_tasks[index]['startDate'].year}-${_tasks[index]['startDate'].month}-${_tasks[index]['startDate'].day}'
                      : 'No start date';
                  String endDate = _tasks[index]['endDate'] != null
                      ? '${_tasks[index]['endDate'].year}-${_tasks[index]['endDate'].month}-${_tasks[index]['endDate'].day}'
                      : 'No end date';
                  return ListTile(
                    title: Text(_tasks[index]['task']),
                    subtitle: Text(
                        'Repeat Every: ${_tasks[index]['repeatInterval']} days\nDate: $startDate - $endDate'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.black,
                      onPressed: () {
                        setState(() {
                          _tasks.removeAt(index);
                          _checkIfGoalIsComplete();
                        });
                      },
                    ),
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
