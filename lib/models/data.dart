import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

// this class will have CalendarEvent data, notes data, streak data
class Event {
  final int id;
  final CalendarEventData event;
  final String? note;
  final List<String>? tags;
  final String? category;
  final bool isCompleted;
  final int streak;

  const Event(
      {required this.id,
      required this.event,
      this.note,
      this.tags,
      this.category = "Home",
      this.isCompleted = false,
      this.streak = 0});
}
