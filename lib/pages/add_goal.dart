import 'package:flutter/material.dart';
import 'add_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dailytask.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flotask/models/event_model.dart';
import 'package:provider/provider.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/components/events_dialog.dart';
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
  bool _isRecurring = false;
  final TextEditingController _descController =
      TextEditingController(); //controller for Description

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
    final eventProvider = context.read<EventProvider>();

    if (goalTitle.isNotEmpty && _tasks.isNotEmpty) {
      // Create the main goal event
      final goalEvent = CalendarEventData(
        title: goalTitle,
        date: _startDate!,
        endDate: _endDate!,
        description: _noteController.text,
      );

      // Add the goal as an event
      await eventProvider.addEvent(
        goalEvent,
        note: _noteController.text,
        tags: [_categoryController.text],
        isRecurring: false,
      );

      // Add each task as a sub-event
      for (final taskData in _tasks) {
        final taskEvent = CalendarEventData(
          title: taskData['task'],
          date: taskData['startDate'],
          endDate: taskData['endDate'],
          description: 'Task for goal: $goalTitle',
          startTime: taskData['selectedTime'] != null
              ? DateTime(
                  taskData['startDate'].year,
                  taskData['startDate'].month,
                  taskData['startDate'].day,
                  int.parse(taskData['selectedTime'].split(':')[0]),
                  int.parse(taskData['selectedTime'].split(':')[1]),
                )
              : null,
        );

        await eventProvider.addEvent(
          taskEvent,
          note: 'Part of goal: $goalTitle',
          tags: [_categoryController.text],
          isRecurring: taskData['repeatInterval'] > 0,
        );
      }

      // Clear data after saving
      _titleController.clear();
      _tasks.clear();
      _categoryController.clear();
      _noteController.clear();
      setState(() {
        _isGoalComplete = false;
        _startDate = null;
        _endDate = null;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaskPage()),
      );
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

    await showDialog(
      context: context,
      builder: (context) => EventDialog(
        eventController: EventController(),
        longPressDate: _startDate,
        longPressEndDate: _endDate,
      ),
    );

    final eventProvider = context.read<EventProvider>();
    final latestEvent = eventProvider.events.last;

    setState(() {
      _tasks.add({
        'task': latestEvent.event.title,
        'startDate': latestEvent.event.date,
        'endDate': latestEvent.event.endDate,
        'repeatInterval': latestEvent.isRecurring ? 1 : 0,
        'selectedTime': latestEvent.event.startTime != null
            ? '${latestEvent.event.startTime!.hour}:${latestEvent.event.startTime!.minute}'
            : null,
      });
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

                    // Recurring Task Checkbox
                    CheckboxListTile(
                      title: const Text("Is this a recurring task?"),
                      value: _isRecurring,
                      onChanged: (bool? value) {
                        setState(() {
                          _isRecurring = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),

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
                            title: Text(
                              _tasks[index]['task'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Repeat Every: ${_tasks[index]['repeatInterval']} days\n'
                              'Date: ${DateFormat('MMM dd, yyyy').format(_tasks[index]['startDate'])} - '
                              '${DateFormat('MMM dd, yyyy').format(_tasks[index]['endDate'])}',
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
