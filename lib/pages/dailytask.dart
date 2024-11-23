import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_goal.dart';
import 'package:flotask/utils/firestore_helpers.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flotask/models/event_model.dart';
import 'package:provider/provider.dart';
import 'package:calendar_view/calendar_view.dart';

//stateful widget for the Taskpage
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  _TaskPageState createState() => _TaskPageState();
}

//state class for TaskPage
class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize event provider
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.loadEventsFromFirebase();
  }

  //dispose the tab controller when not needed
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateRecurrenceStatus(
      DocumentReference recurrenceRef,
      DocumentReference taskRef,
      DocumentReference goalRef,
      bool isCompleted) async {
    await updateRecurrenceStatus(
      recurrenceRef: recurrenceRef,
      taskRef: taskRef,
      goalRef: goalRef,
      isCompleted: isCompleted,
    );
  }

  //helper function to update the completion status of a specific recurrence
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Function to build the list of today's recurrences for a given status
  Widget _buildTaskList(String status) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        // Filter events based on completion status only
        final filteredEvents = eventProvider.events.where((event) {
          final eventStatus = event.isCompleted ? 'completed' : 'todo';
          return eventStatus == status;
        }).toList();

        if (filteredEvents.isEmpty) {
          return Center(child: Text('No ${status} tasks'));
        }

        return ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];

            return ListTile(
              leading: Checkbox(
                value: event.isCompleted,
                onChanged: (bool? value) async {
                  if (value != null) {
                    await eventProvider.toggleComplete(event.id!, value);
                  }
                },
              ),
              title: Text(event.event.title),
              subtitle: Text(
                'Time: ${event.event.startTime != null ? TimeOfDay.fromDateTime(event.event.startTime!).format(context) : 'Any time'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editTask(event);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //work review3
  // Function to edit a task
  Future<void> _editTask(EventModel event) async {
    final TextEditingController _taskController =
        TextEditingController(text: event.event.title);

    TimeOfDay? initialTime;
    if (event.event.startTime != null) {
      initialTime = TimeOfDay.fromDateTime(event.event.startTime!);
    }

    setState(() {
      _selectedTime = initialTime;
    });

    String _selectedOption =
        _selectedTime != null ? 'Specific time' : 'Any time';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Time Selection
                    const Text(
                      'Time',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Time:'),
                        DropdownButton<String>(
                          value: _selectedOption,
                          items: <String>['Any time', 'Specific time']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedOption = newValue!;
                              if (newValue == 'Specific time') {
                                _selectTime(context, setState, _selectedTime);
                              } else {
                                _selectedTime = null;
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    // Display the selected time if specific time is chosen
                    if (_selectedOption == 'Specific time' &&
                        _selectedTime != null)
                      Text('Selected Time: ${_selectedTime!.format(context)}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final eventProvider = context.read<EventProvider>();
                    await eventProvider.updateEventDetails(
                      event.id!,
                      title: _taskController.text,
                      startTime: _selectedTime != null
                          ? DateTime(
                              event.event.date.year,
                              event.event.date.month,
                              event.event.date.day,
                              _selectedTime!.hour,
                              _selectedTime!.minute,
                            )
                          : null,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to delete a task
  Future<void> _deleteTask(DocumentReference taskRef) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await taskRef.delete();
                // Close the confirmation dialog
                Navigator.of(context).pop();
                // Close the edit dialog
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Add this method to create an event from a task
  Future<void> _createEventFromTask(String taskName, DateTime startDate,
      DateTime endDate, String? selectedTime) async {
    final eventData = CalendarEventData(
      title: taskName,
      date: startDate,
      endDate: endDate,
      startTime: selectedTime != null
          ? DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
              int.parse(selectedTime.split(':')[0]),
              int.parse(selectedTime.split(':')[1]))
          : startDate,
      endTime: selectedTime != null
          ? DateTime(
              endDate.year,
              endDate.month,
              endDate.day,
              int.parse(selectedTime.split(':')[0]) + 1,
              int.parse(selectedTime.split(':')[1]))
          : endDate,
    );

    await context.read<EventProvider>().addEvent(
          eventData,
          note: "Task created from daily tasks",
          tags: ["task"],
          isRecurring: true,
        );
  }

  // Add this method
  Future<void> _selectTime(BuildContext context, StateSetter setDialogState,
      TimeOfDay? currentTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setDialogState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          //appBar with title and tabs
          appBar: AppBar(
            title: Center(
              child: Text(
                "Daily tasks", //page title
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: const Color(0xFFEBEAE3),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'To-do'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          //content of each tab
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList('todo'),
              _buildTaskList('completed'),
            ],
          ),
          //floating action button to ass a new goal
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              onPressed: () {
                //navigate to add goal page when clicking on the button
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddGoalPage()),
                );
              },
              backgroundColor: Colors.black,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
