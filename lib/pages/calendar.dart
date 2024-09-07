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

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Calendar View"),
          bottom: TabBar(
            controller: tabController,
            tabs: [Text("Month View"), Text("Week View"), Text("Day View")],
          ),
        ),
        body: TabBarView(
            controller: tabController,
            children: [MonthView(), WeekView(), DayView()]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => const EventDialog());
          },
        ));
  }
}
