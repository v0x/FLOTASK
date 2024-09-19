import 'package:flotask/components/event_note.dart';
import 'package:flotask/components/events_dialog.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/main.dart';
import 'package:provider/provider.dart';

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
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text("Event List"),
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(
                              context); // Pops the current page and goes back
                        },
                      ),
                    ),
                    body: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(9),
                            child: Text("Events on $date"),
                          ),
                        ),
                        ...events.map((event) => ListTile(
                              title: Text(event.title),
                              subtitle:
                                  Text('${event.date} - ${event.endDate}'),
                            ))
                      ],
                    ),
                  ),
                ),
              );
            },
            onEventTap: (event, date) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text("$event Details"),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(
                                context); // Pops the current page and goes back
                          },
                        ),
                      ),
                      body: EventDetailWithNotes(),
                    ),
                  ));
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
          WeekView(
            controller: _eventController,
            onEventTap: (event, date) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text("$event Details"),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(
                                context); // Pops the current page and goes back
                          },
                        ),
                      ),
                      body: EventDetailWithNotes(),
                    ),
                  ));
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
            onEventTap: (event, date) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text("$event Details"),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(
                                context); // Pops the current page and goes back
                          },
                        ),
                      ),
                      body: EventDetailWithNotes(),
                    ),
                  ));
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
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => EventDialog(
                      eventController: _eventController,
                    ));
          },
        ),
        drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Notes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ...eventProvider.events.map((e) => ListTile(
                  title: Text(e.note.toString()),
                ))
          ]),
        ));
  }
}
