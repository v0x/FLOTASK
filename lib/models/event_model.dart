import 'package:calendar_view/calendar_view.dart';
import 'package:uuid/uuid.dart';

// Model class for a user-created event; used globally for every feature
class EventModel {
  final String id;
  CalendarEventData event;
  String? note;
  List<String>? tags;
  String? category;

// default type of task for user; for notifications
  bool isReminder;

  // for checkbox tasks
  bool isCompleted;
  int dayStreak;
  int monthStreak;
  int yearStreak;

  // for recurring tasks aka habit tasks; will be shown in habit section of task page
  bool isRecurring;

  // to keep track of when the user completes a task
  DateTime? lastCompletedDate;

  EventModel({
    required this.event,
    this.note,
    this.tags,
    this.category = "Home",
    this.isCompleted = false,
    this.dayStreak = 0,
    this.monthStreak = 0,
    this.yearStreak = 0,
    this.isRecurring = false,
    this.isReminder = true,
    this.lastCompletedDate,
  }) : id = Uuid().v4();
}
