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
                  itemCount: eventProvider.events
                      .where((element) => element.isArchived)
                      .length,
                  itemBuilder: (context, index) {
                    final archivedEvents = eventProvider.events
                        .where((element) => element.isArchived)
                        .toList();

                    final archivedEvent = archivedEvents[index];

                    return ListTile(
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: ListView.builder(
          itemCount: eventProvider.events.length,
          itemBuilder: (context, index) {
            final event = eventProvider.events[index];
            return ListTile(
              title: Text(event.event.title),
              subtitle: Text(
                  '${DateFormat('h:mm a').format(event.event.date)} - ${DateFormat('h:mm a').format(event.event.endTime!)}'),
              onTap: () {
                // Navigate to the event detail page when clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailWithNotes(event: event),
                  ),
                );
              },
            );
          },
        ));
  }
}
