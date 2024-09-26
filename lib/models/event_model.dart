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
  int streak;

  // for recurring tasks aka habit tasks; will be shown in habit section of task page
  bool isRecurring;

  // to keep track of when the user completes a task
  DateTime? lastCompletedDate;

  Recurrence? recurrenceType;

  EventModel(
      {required this.event,
      this.note,
      this.tags,
      this.category = "Home",
      this.isCompleted = false,
      this.streak = 0,
      this.isRecurring = false,
      this.isReminder = true,
      this.lastCompletedDate,
      this.recurrenceType})
      : id = Uuid().v4();
}

// type of recurrence to take into account when using streaks
enum Recurrence { daily, monthly, yearly }
