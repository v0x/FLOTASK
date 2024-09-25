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
                // Wrap the ListView.builder in Expanded to give it available space
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

                    return Slidable(
                        endActionPane:
                            ActionPane(motion: ScrollMotion(), children: [
                          SlidableAction(
                            // An action can be bigger than the others.
                            flex: 2,
                            onPressed: (context) {
                              context
                                  .read<EventProvider>()
                                  .unarchiveNote(archivedEvent.id);
                            },
                            backgroundColor: Color(0xFF7BC043),
                            foregroundColor: Colors.white,
                            icon: Icons.archive,
                            label: 'Unarchive',
                          ),
                        ]),
                        child: ListTile(
                          title: Text(archivedEvent.event
                              .title), // assuming title is directly in archivedEvent
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

            return Slidable(
                // The end action pane is the one at the right or the bottom side.
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      // An action can be bigger than the others.
                      flex: 2,
                      onPressed: (context) {
                        context.read<EventProvider>().archiveNote(event.id);
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
                child: Container(
                  color:
                      event.isArchived ? Colors.grey[400] : Colors.transparent,
                  child: ListTile(
                    title: Text(
                      event.event.title,
                      style: TextStyle(
                        decoration: event.isArchived
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                        '${DateFormat('h:mm a').format(event.event.date)} - ${DateFormat('h:mm a').format(event.event.endTime!)}'),
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
