import 'package:flotask/components/event_note_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flotask/models/event_provider.dart';

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
                              context
                                  .read<EventProvider>()
                                  .updateArchivedStatus(archivedEvent.id!,
                                      archivedEvent.isArchived);
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
          itemCount: eventProvider.events.length,
          itemBuilder: (context, index) {
            final event = eventProvider.events[index];

            // Get the border color based on the streak levels
            final borderColor = getStreakColor(event.dayStreak ?? 0,
                event.monthStreak ?? 0, event.yearStreak ?? 0);

            return Slidable(
                // The end action pane is the one at the right or the bottom side.
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      // An action can be bigger than the others.
                      flex: 2,
                      onPressed: (context) {
                        context.read<EventProvider>().archiveNote(event.id!);
                        context
                            .read<EventProvider>()
                            .updateArchivedStatus(event.id!, event.isArchived);
                      },
                      backgroundColor: Color(0xFF7BC043),
                      foregroundColor: Colors.white,
                      icon: Icons.archive,
                      label: 'Archive',
                    ),
                    // SlidableAction(
                    //   // onPressed: doNothing,
                    //   backgroundColor: Color(0xFF0392CF),
                    //   foregroundColor: Colors.white,
                    //   icon: Icons.save,
                    //   label: 'Save',
                    // ),
                  ],
                ),

                // logic to show crossed out text and gray background
                child: Container(
                  decoration: BoxDecoration(
                    color: event.isArchived
                        ? Colors.grey[400]
                        : Colors.transparent,
                    border: Border.all(
                      color: borderColor, // Apply the streak color as a border
                      width: 2.0,
                    ),
                  ),
                  // color:
                  //     event.isArchived ? Colors.grey[400] : Colors.transparent,
                  child: ListTile(
                    title: Row(
                      children: [
                        // Conditionally show checkbox for recurring tasks
                        if (event.isRecurring)
                          Checkbox(
                            value: event
                                .isCompleted, // Assuming event has an isCompleted property
                            onChanged: (bool? value) {
                              setState(() {
                                // Update the completion status of the recurring event
                                eventProvider.toggleComplete(
                                    event.id!, value ?? false);

                                if (value == true) {
                                  eventProvider.updateStreak(event.id!);
                                }
                              });
                            },
                          ),
                        Expanded(
                          child: Text(
                            event.event.title,
                            style: TextStyle(
                              decoration: event.isArchived
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // child: ListTile(
                    //   title: Text(
                    //     event.event.title,
                    //     style: TextStyle(
                    //       decoration: event.isArchived
                    //           ? TextDecoration.lineThrough
                    //           : TextDecoration.none,
                    //     ),
                    //   ),
                    subtitle: Text(
                        '${DateFormat('h:mm a').format(event.event.date)} - ${DateFormat('h:mm a').format(event.event.endTime!)} \nStreak: ${event.dayStreak!}'),
                    onTap: () {
                      // Navigate to the event detail page when clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventDetailWithNotes(event: event),
                        ),
                      );
                    },
                  ),
                ));
          },
        ));
  }
}
