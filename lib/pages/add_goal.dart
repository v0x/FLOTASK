import 'package:flutter/material.dart';
import 'add_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dailytask.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flotask/models/event_model.dart';
import 'package:provider/provider.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/components/events_dialog.dart';

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

    // The task will be added to the EventProvider automatically
    // We just need to update our local state
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
