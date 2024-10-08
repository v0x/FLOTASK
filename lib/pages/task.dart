import 'package:flotask/components/event_note_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flotask/models/event_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  // Method to determine the color based on streak type
  Color getStreakColor(int dayStreak, int monthStreak, int yearStreak) {
    if (yearStreak > 0) {
      return Colors.yellow; // Yearly streak - gold color
    } else if (monthStreak > 0) {
      return Colors.blue; // Monthly streak - blue color
    } else if (dayStreak > 0) {
      return Colors.green; // Daily streak - green color
    } else {
      return Colors.transparent; // No streak - no border
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();

    // Separate completed and uncompleted tasks
    final uncompletedTasks = eventProvider.events
        .where((event) => !event.isCompleted && !event.isArchived)
        .toList();
    final completedTasks = eventProvider.events
        .where((event) => event.isCompleted && !event.isArchived)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Page'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // the right side of appbar drawer
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

      // side drawer to display list of archived tasks
      endDrawer: Drawer(
        child: Column(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Archived Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                // only show archived tasks
                itemCount: eventProvider.events
                    .where((element) => element.isArchived)
                    .length,
                itemBuilder: (context, index) {
                  final archivedEvents = eventProvider.events
                      .where((element) => element.isArchived)
                      .toList();

                  final archivedEvent = archivedEvents[index];

// slidable library used here. the child property is the actual widget being shown
                  return Slidable(
                      endActionPane:
                          ActionPane(motion: ScrollMotion(), children: [
                        SlidableAction(
                          // An action can be bigger than the others.
                          flex: 2,
                          onPressed: (context) {
                            context
                                .read<EventProvider>()
                                .unarchiveNote(archivedEvent.id!);
                            context.read<EventProvider>().updateArchivedStatus(
                                archivedEvent.id!, archivedEvent.isArchived);
                          },
                          backgroundColor: Color(0xFF7BC043),
                          foregroundColor: Colors.white,
                          icon: Icons.archive,
                          label: 'Unarchive',
                        ),
                      ]),
                      child: ListTile(
                        title: Text(archivedEvent.event.title),
                        subtitle: Text(
                            '${DateFormat('h:mm a').format(archivedEvent.event.date)} - ${DateFormat('h:mm a').format(archivedEvent.event.endTime!)}'),
                        onTap: () {
                          // Navigate to the event detail page when clicked
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailWithNotes(event: archivedEvent),
                            ),
                          );
                        },
                      ));
                },
              ),
            ),
          ],
        ),
      ),

      // actual list of tasks in task page NOT side drawer
      body: ListView.builder(
        itemCount: uncompletedTasks.length + completedTasks.length + 1,
        itemBuilder: (context, index) {
          if (index < uncompletedTasks.length) {
            return _buildTaskItem(uncompletedTasks[index], context);
          } else if (index == uncompletedTasks.length) {
            return Padding(
              padding: EdgeInsets.all(8),
              child: Text('Completed Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          } else {
            return _buildTaskItem(
                completedTasks[index - uncompletedTasks.length - 1], context);
          }
        },
      ),
    );
  }

// refactor to new widget that will be used for both uncompleted and completed tasks
  Widget _buildTaskItem(EventModel event, BuildContext context) {
    final borderColor = getStreakColor(
        event.dayStreak ?? 0, event.monthStreak ?? 0, event.yearStreak ?? 0);

    final eventProvider = context.read<EventProvider>();

    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (context) {
              eventProvider.archiveNote(event.id!);
              eventProvider.updateArchivedStatus(event.id!, true);
            },
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: event.isArchived ? Colors.grey[400] : Colors.transparent,
          border: Border.all(
            color: borderColor,
            width: 2.0,
          ),
        ),
        child: ListTile(
          leading: Checkbox(
            value: event.isCompleted,
            onChanged: (bool? value) {
              eventProvider.toggleComplete(event.id!, value ?? false);
              if (value == true && event.isRecurring) {
                eventProvider.updateStreak(event.id!);
              }
            },
          ),
          title: Text(
            event.event.title,
            style: TextStyle(
              decoration: event.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${DateFormat('h:mm a').format(event.event.date)} - ${DateFormat('h:mm a').format(event.event.endTime!)}'),
              if (event.isRecurring) Text('Streak: ${event.dayStreak!} days'),
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
      ),
    );
  }
}
