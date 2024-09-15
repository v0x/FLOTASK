import 'package:flotask/pages/events_dialog.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/main.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  EventController _eventController = EventController();

  String selectedPage = '';

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final eventController = CalendarControllerProvider.of(context).controller;
    return Scaffold(
        appBar: AppBar(
          title: Text("Calendar View"),
          bottom: TabBar(
            controller: tabController,
            tabs: [Text("Month View"), Text("Week View"), Text("Day View")],
          ),
        ),
        body: TabBarView(controller: tabController, children: [
          MonthView(controller: _eventController), // Pass the EventController
          WeekView(controller: _eventController),
          DayView(controller: _eventController),
        ]),
        floatingActionButton: FloatingActionButton(
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
            ..._eventController
                .getEventsOnDay(DateTime.now())
                .map((event) => ListTile(
                      title: Text(event.title),
                      subtitle: Text('${event.date} - ${event.endDate}'),
                    )),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("hello"),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {
                setState(() {
                  selectedPage = 'Messages';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                setState(() {
                  selectedPage = 'Profile';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  selectedPage = 'Settings';
                });
              },
            ),
          ]),
        ));
  }
}
