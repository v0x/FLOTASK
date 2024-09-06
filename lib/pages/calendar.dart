import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/main.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return MonthView(
      controller: EventController()..addAll(events),
      // // to provide custom UI for month cells.
      // cellBuilder: (date, events, isToday, isInMonth) {
      //   // Return your widget to display as month cell.
      //   return Container();
      // },
      minMonth: DateTime(1990),
      maxMonth: DateTime(2050),
      initialMonth: DateTime(2021),
      cellAspectRatio: 1,
      onPageChange: (date, pageIndex) => print("$date, $pageIndex"),
      onCellTap: (events, date) {
        // Implement callback when user taps on a cell.
        print(events);
      },
      startDay: WeekDays.sunday, // To change the first day of the week.
      // This callback will only work if cellBuilder is null.
      onEventTap: (event, date) => print(event),
      onEventDoubleTap: (events, date) => print(events),
      onEventLongTap: (event, date) => print(event),
      onDateLongPress: (date) => print(date),
      headerBuilder: MonthHeader.hidden, // To hide month header
      showWeekTileBorder: false, // To show or hide header border
      hideDaysNotInMonth:
          true, // To hide days or cell that are not in current month
    );
  }
}

DateTime get now => DateTime.now();

List<CalendarEventData> events = [
  CalendarEventData(
    date: now,
    title: "Project meeting",
    description: "Today is project meeting.",
    startTime: DateTime(now.year, now.month, now.day, 18, 30),
    endTime: DateTime(now.year, now.month, now.day, 22),
  ),
  CalendarEventData(
    date: now.add(Duration(days: 1)),
    startTime: DateTime(now.year, now.month, now.day, 18),
    endTime: DateTime(now.year, now.month, now.day, 19),
    title: "Wedding anniversary",
    description: "Attend uncle's wedding anniversary.",
  ),
  CalendarEventData(
    date: now,
    startTime: DateTime(now.year, now.month, now.day, 14),
    endTime: DateTime(now.year, now.month, now.day, 17),
    title: "Football Tournament",
    description: "Go to football tournament.",
  ),
  CalendarEventData(
    date: now.add(Duration(days: 3)),
    startTime: DateTime(now.add(Duration(days: 3)).year,
        now.add(Duration(days: 3)).month, now.add(Duration(days: 3)).day, 10),
    endTime: DateTime(now.add(Duration(days: 3)).year,
        now.add(Duration(days: 3)).month, now.add(Duration(days: 3)).day, 14),
    title: "Sprint Meeting.",
    description: "Last day of project submission for last year.",
  ),
  CalendarEventData(
    date: now.subtract(Duration(days: 2)),
    startTime: DateTime(
        now.subtract(Duration(days: 2)).year,
        now.subtract(Duration(days: 2)).month,
        now.subtract(Duration(days: 2)).day,
        14),
    endTime: DateTime(
        now.subtract(Duration(days: 2)).year,
        now.subtract(Duration(days: 2)).month,
        now.subtract(Duration(days: 2)).day,
        16),
    title: "Team Meeting",
    description: "Team Meeting",
  ),
  CalendarEventData(
    date: now.subtract(Duration(days: 2)),
    startTime: DateTime(
        now.subtract(Duration(days: 2)).year,
        now.subtract(Duration(days: 2)).month,
        now.subtract(Duration(days: 2)).day,
        10),
    endTime: DateTime(
        now.subtract(Duration(days: 2)).year,
        now.subtract(Duration(days: 2)).month,
        now.subtract(Duration(days: 2)).day,
        12),
    title: "Chemistry Viva",
    description: "Today is Joe's birthday.",
  ),
];
