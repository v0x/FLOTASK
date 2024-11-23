import 'package:flotask/components/event_note_details.dart';
import 'package:flotask/components/events_dialog.dart';
import 'package:flotask/models/event_model.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// the calendar widget to show the MOnth view, Week View, and day view. There are also onTap, onEventTap, and on DateTap functions to route to different pages
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  // to manage tabs
  TabController? tabController;

// to manage events
  EventController _eventController = EventController();

  String selectedPage = '';

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();

    // Load events from Firebase on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsFromFirebase();
    });
  }

  void _loadEventsFromFirebase() async {
    final eventProvider = context.read<EventProvider>();
    await eventProvider.loadEventsFromFirebase();

    // After loading events from Firebase, add them to the EventController
    // _eventController.removeWhere((_) => true); // Clear existing events
    for (var event in eventProvider.events) {
      _eventController.add(event.event);
    }
    setState(() {}); // Trigger a rebuild to reflect the changes
  }

  @override
  Widget build(BuildContext context) {
    // get the state of the events with this line
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
        appBar: AppBar(
          title: Text("Calendar View"),
          bottom: TabBar(
            controller: tabController,
            tabs: [Text("Month View"), Text("Week View"), Text("Day View")],
          ),
        ),

        // tab view of month, day, year
        body: TabBarView(controller: tabController, children: [
          MonthView(
            controller: _eventController,

            // tap function to view event details page of the day
            onCellTap: (events, date) {
              String formattedDate = DateFormat('MMMM d, y').format(date);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text("$formattedDate Event List"),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(
                                context); // Pops the current page and goes back
                          },
                        ),
                      ),

                      // route to a detailed list view of each task
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
                                  builder: (context) =>
                                      EventDetailWithNotes(event: event),
                                ),
                              );
                            },
                          );
                        },
                      )),
                ),
              );
            },

            // function to route to a detailed view of a SPECIFIC task
            onEventTap: (event, date) {
              EventModel eventModel = EventModel(event: event);
              final eventProvider = context.read<EventProvider>();
              EventModel? foundEvent = eventProvider.events.firstWhere(
                  (element) => element.event.hashCode == event.hashCode);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EventDetailWithNotes(event: foundEvent)));
            },

            // quick way to create an event with an already filled date in the dialog
            onDateLongPress: (date) {
              showDialog(
                context: context,
                builder: (BuildContext context) => EventDialog(
                  eventController: _eventController,
                  longPressDate: date,
                ),
              );
            },
          ),
          WeekView(
            controller: _eventController,

            // function to route to a detailed view of a SPECIFIC task
            onEventTap: (event, date) {
              final eventProvider = context.read<EventProvider>();
              EventModel? foundEvent = eventProvider.events.firstWhere(
                  (element) => element.event.hashCode == event.first.hashCode);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EventDetailWithNotes(event: foundEvent)));
            },

            onDateLongPress: (date) {
              showDialog(
                context: context,
                builder: (BuildContext context) => EventDialog(
                  eventController: _eventController,
                  longPressDate: date,
                ),
              );
            },
          ),
          DayView(
            controller: _eventController,

            // function to route to a detailed view of a SPECIFIC task
            onEventTap: (event, date) {
              final eventProvider = context.read<EventProvider>();
              EventModel? foundEvent = eventProvider.events.firstWhere(
                  (element) => element.event.hashCode == event.first.hashCode);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EventDetailWithNotes(event: foundEvent)));
            },

            onDateLongPress: (date) {
              showDialog(
                context: context,
                builder: (BuildContext context) => EventDialog(
                  eventController: _eventController,
                  longPressDate: date,
                ),
              );
            },
          ),
        ]),

        // action button to show a dialog to input a calendar event
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.add),
        //   onPressed: () {
        //     showDialog(
        //         context: context,
        //         builder: (BuildContext context) => EventDialog(
        //               eventController: _eventController,
        //             ));
        //   },
        // ),

        //floating action button to add a new goal
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            onPressed: () {
              //navigate to event dialog when clicking on the button
              showDialog(
                context: context,
                builder: (BuildContext context) => EventDialog(
                  eventController: _eventController,
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
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  color: const Color(0xFFEBEAE3),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.note_alt_outlined,
                          color: Colors.black, size: 30),
                      const SizedBox(width: 10),
                      const Text(
                        'Notes',
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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      ...eventProvider.events.map((e) => Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                e.event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    e.note?.toString() ?? 'No notes',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(e.event.date),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailWithNotes(event: e),
                                  ),
                                );
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
