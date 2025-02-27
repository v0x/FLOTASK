import 'package:flutter/material.dart';
import 'add_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //Import Firestore
import 'dailytask.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; //Import Color Picker
import 'package:flutter/services.dart'; //For input formatters
//import 'package:flotask/models/event_provider.dart';
//import 'package:flotask/models/event_model.dart';
//import 'package:provider/provider.dart';
//import 'package:calendar_view/calendar_view.dart';
//import 'package:flotask/components/events_dialog.dart';
import 'package:intl/intl.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _titleController = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];

  bool _isGoalComplete = false;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  //bool _isRecurring = false;
  final TextEditingController _descController =
      TextEditingController(); //controller for Description

  // Controllers and Variables for New Fields
  final TextEditingController _workTimeController =
      TextEditingController(); // Controller for work time
  final TextEditingController _breakTimeController =
      TextEditingController(); // Controller for break time
  Color _selectedColor = Colors.blue; // Default color

  void _checkIfGoalIsComplete() {
    setState(() {
      _isGoalComplete =
          _titleController.text.isNotEmpty && _tasks.isNotEmpty;
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
    //get current user's UID
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to log in to save a goal.')),
      );
      return;
    }
    final String userId = currentUser.uid;
    //final eventProvider = context.read<EventProvider>();

    if (goalTitle.isNotEmpty && _tasks.isNotEmpty) {
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
            'workTime': taskData['workTime'], // Save Work Time
            'breakTime': taskData['breakTime'], // Save Break Time
            'color': taskData['color'], // Save Color as Hex String
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

      // // Create the main goal event
      // final goalEvent = CalendarEventData(
      //   title: goalTitle,
      //   date: _startDate!,
      //   endDate: _endDate!,
      //   description: _noteController.text,
      // );

      // // Add the goal as an event
      // await eventProvider.addEvent(
      //   goalEvent,
      //   note: _noteController.text,
      //   tags: [_categoryController.text],
      //   isRecurring: false,
      // );

      // // Add each task as a sub-event
      // for (final taskData in _tasks) {
      //   final taskEvent = CalendarEventData(
      //     title: taskData['task'],
      //     date: taskData['startDate'],
      //     endDate: taskData['endDate'],
      //     description: 'Task for goal: $goalTitle',
      //     startTime: taskData['selectedTime'] != null
      //         ? DateTime(
      //             taskData['startDate'].year,
      //             taskData['startDate'].month,
      //             taskData['startDate'].day,
      //             int.parse(taskData['selectedTime'].split(':')[0]),
      //             int.parse(taskData['selectedTime'].split(':')[1]),
      //           )
      //         : null,
      //   );

      //   await eventProvider.addEvent(
      //     taskEvent,
      //     note: 'Part of goal: $goalTitle',
      //     tags: [_categoryController.text],
      //     isRecurring: taskData['repeatInterval'] > 0,
      //   );
      // }

      // Clear data after saving
      _titleController.clear();
      _tasks.clear();
      _categoryController.clear();
      _noteController.clear();
      _workTimeController.clear(); // Clear Work Time
      _breakTimeController.clear(); // Clear Break Time
      setState(() {
        _isGoalComplete = false;
        //_startDate = null;
        //_endDate = null;
      });

      // //navigate to the Daily task view
      Navigator.of(context).pop();

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const DailyTaskPage()),
      // );
    }
  }

  void _navigateToAddTask() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates for the goal.'),
        ),
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

    // await showDialog(
    //   context: context,
    //   builder: (context) => EventDialog(
    //     eventController: EventController(),
    //     longPressDate: _startDate,
    //     longPressEndDate: _endDate,
    //   ),
    // );

    //final eventProvider = context.read<EventProvider>();
    //final latestEvent = eventProvider.events.last;

    // setState(() {
    //   _tasks.add({
    //     'task': latestEvent.event.title,
    //     'startDate': latestEvent.event.date,
    //     'endDate': latestEvent.event.endDate,
    //     'repeatInterval': latestEvent.isRecurring ? 1 : 0,
    //     'selectedTime': latestEvent.event.startTime != null
    //         ? '${latestEvent.event.startTime!.hour}:${latestEvent.event.startTime!.minute}'
    //         : null,
    //   });
    // });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    _workTimeController.dispose(); // Dispose Work Time Controller
    _breakTimeController.dispose(); // Dispose Break Time Controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEAE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBEAE3),
        elevation: 0,
        title: const Text(
          'Add Goal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isGoalComplete ? _saveGoal : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isGoalComplete ? Colors.black : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title Field
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Goal Title',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => _checkIfGoalIsComplete(),
                    ),
                    const SizedBox(height: 16.0),

                    // Date Selection
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _selectDate(context, _startDate, (date) {
                              setState(() {
                                _startDate = date;
                              });
                            }),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _startDate == null
                                  ? 'Start Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_startDate!),
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _selectDate(context, _endDate, (date) {
                              setState(() {
                                _endDate = date;
                              });
                            }),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _endDate == null
                                  ? 'End Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_endDate!),
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Category Field
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Description Field
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 7,
                    ),
                    const SizedBox(height: 16.0),

                    // Note Field
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // // Recurring Task Checkbox
                    // CheckboxListTile(
                    //   title: const Text("Is this a recurring task?"),
                    //   value: _isRecurring,
                    //   onChanged: (bool? value) {
                    //     setState(() {
                    //       _isRecurring = value ?? false;
                    //     });
                    //   },
                    // ),
                    // const SizedBox(height: 16.0),

                    // Tasks for this Goal
                    const Text(
                      'Tasks for this Goal',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),

                    // Add Task Button
                    ElevatedButton(
                      onPressed: _navigateToAddTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7BC043),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Task'),
                    ),
                    const SizedBox(height: 16.0),

                    // Task List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(int.parse(
                                    _tasks[index]['color'], radix: 16)),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                              ),
                            ), // Display selected color
                            title: Text(
                              _tasks[index]['task'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Repeat Every: ${_tasks[index]['repeatInterval']} days',
                                ),
                                Text(
                                  'Date: ${DateFormat('MMM dd, yyyy').format(_tasks[index]['startDate'])} - '
                                  '${DateFormat('MMM dd, yyyy').format(_tasks[index]['endDate'])}',
                                ),
                                if (_tasks[index]['selectedTime'] != null)
                                  Text(
                                      'Time: ${_tasks[index]['selectedTime']}'), // Display selected time
                                Text(
                                    'Work Time: ${_tasks[index]['workTime']} minutes'), // Display Work Time
                                Text(
                                    'Break Time: ${_tasks[index]['breakTime']} minutes'), // Display Break Time
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _tasks.removeAt(index);
                                  _checkIfGoalIsComplete();
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
