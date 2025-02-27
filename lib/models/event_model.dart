import 'package:calendar_view/calendar_view.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model class for a user-created event, used globally for every feature
class EventModel {
  String? id;
  final DocumentReference? ref;
  CalendarEventData event;
  String? note;
  final List<String>? tags;
  final String? category;

// default type of task for user; for notifications
  bool isReminder;

  // for checkbox tasks
  bool isCompleted;

  // for streaks functionality
  int dayStreak;
  int monthStreak;
  int yearStreak;

  // for recurring tasks aka habit tasks; will be shown in habit section of task page
  bool isRecurring;

  // to keep track of when the user completes a task
  DateTime? lastCompletedDate;

// for archive list functionality
  bool isArchived;

  // add voice memos STT
  String? voiceMemos;

  EventModel(
      {this.id,
      this.ref,
      required this.event,
      this.note,
      this.tags,
      this.category,
      this.isCompleted = false,
      this.dayStreak = 0,
      this.monthStreak = 0,
      this.yearStreak = 0,
      this.isRecurring = false,
      this.isReminder = false,
      this.lastCompletedDate,
      this.isArchived = false,
      this.voiceMemos});
}
