import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_goal.dart';
import 'package:flotask/utils/firestore_helpers.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flotask/models/event_model.dart';
import 'package:provider/provider.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/components/events_dialog.dart';
import 'package:intl/intl.dart';
import 'package:flotask/components/event_note_details.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
        final filteredEvents = eventProvider.events.where((event) {
          final eventStatus = event.isCompleted ? 'completed' : 'todo';
          return eventStatus == status && !event.isArchived;
        }).toList();

        if (filteredEvents.isEmpty) {
          return Center(child: Text('No ${status} tasks'));
        }

        return ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];

            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    flex: 2,
                    onPressed: (context) {
                      // Archive the event
                      context
                          .read<EventProvider>()
                          .updateArchivedStatus(event.id!, false);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${event.event.title} archived')),
                      );
                    },
                    backgroundColor: const Color(0xFF7BC043),
                    foregroundColor: Colors.white,
                    icon: Icons.archive,
                    label: 'Archive',
                  ),
                ],
              ),
              child: ListTile(
                leading: Checkbox(
                  value: event.isCompleted,
                  onChanged: (bool? value) async {
                    if (value != null) {
                      await eventProvider.toggleComplete(event.id!, value);
                      if (value && event.isRecurring) {
                        // Update streak when completing a recurring task
                        await eventProvider.updateStreak(event.id!);
                      }
                    }
                  },
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.event.title,
                        style: TextStyle(
                          decoration: event.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    if (event.isRecurring) ...[
                      Text(
                        _getStreakFlair(event),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 4),
                      if (event.dayStreak != null && event.dayStreak! > 0)
                        Text(
                          '${event.dayStreak}d',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(event.event.date)}',
                    ),
                    Text('${event.event.startTime != null ? '${TimeOfDay.fromDateTime(event.event.startTime!).format(context)} - '
                        '${event.event.endTime != null ? TimeOfDay.fromDateTime(event.event.endTime!).format(context) : ''}' : 'Any time'}'),
                  ],
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailWithNotes(event: event),
                    ),
                  );
                },
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
    final eventController = EventController()..addAll([event.event]);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Provider<EventController>(
        create: (context) => eventController,
        child: EventDialog(
          eventController: eventController,
          longPressDate: event.event.date,
          longPressEndDate: event.event.endDate,
          isEditing: true,
          existingEvent: event,
        ),
      ),
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

  // create an event from a task
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

  String _getStreakFlair(EventModel event) {
    if (event.yearStreak != null && event.yearStreak! > 0) {
      return '🏆';
    } else if (event.monthStreak != null && event.monthStreak! > 0) {
      return '🥈';
    } else if (event.dayStreak != null && event.dayStreak! > 0) {
      return '🥉';
    }
    return '';
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
                "Tasks",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: const Color(0xFFEBEAE3),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'To-do'),
                Tab(text: 'Completed'),
              ],
            ),
          ),

          // archive list side drawer
          endDrawer: Drawer(
            child: Column(
              children: <Widget>[
                Container(
                  color: const Color(0xFFEBEAE3),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.archive, color: Colors.black, size: 30),
                      const SizedBox(width: 10),
                      const Text(
                        'Archived Tasks',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      final archivedEvents = eventProvider.events
                          .where((element) => element.isArchived)
                          .toList();

                      return ListView.builder(
                        itemCount: archivedEvents.length,
                        itemBuilder: (context, index) {
                          final archivedEvent = archivedEvents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            elevation: 4,
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    flex: 2,
                                    onPressed: (context) {
                                      context
                                          .read<EventProvider>()
                                          .updateArchivedStatus(
                                              archivedEvent.id!, true);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                '${archivedEvent.event.title} unarchived')),
                                      );
                                    },
                                    backgroundColor: const Color(0xFF7BC043),
                                    foregroundColor: Colors.white,
                                    icon: Icons.unarchive,
                                    label: 'Unarchive',
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  archivedEvent.event.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  '${DateFormat('h:mm a').format(archivedEvent.event.date)} - ${DateFormat('h:mm a').format(archivedEvent.event.endTime!)}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailWithNotes(
                                              event: archivedEvent),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
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
          //floating action button to add a new goal
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              onPressed: () {
                //navigate to event dialog when clicking on the button
                showDialog(
                  context: context,
                  builder: (BuildContext context) => EventDialog(
                    eventController: EventController(),
                  ),
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
