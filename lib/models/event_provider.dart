import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:calendar_view/calendar_view.dart';
import 'event_model.dart';

// the global state for handling all events within our app
class EventProvider extends ChangeNotifier {
  // List of events
  List<EventModel> _events = [];

  // Get the list of events
  List<EventModel> get events => _events;

  // Method to add a new event
  void addEvent(CalendarEventData eventData,
      {String? note, List<String>? tags}) {
    final newEvent = EventModel(
      event: eventData,
      note: note,
      tags: tags,
    );

    _events.add(newEvent);
    notifyListeners();
  }

  // Method to remove an event
  void removeEvent(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
    notifyListeners();
  }

  // Method to update an existing event (if needed)
  void updateEvent(String eventId, CalendarEventData updatedEventData) {
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      _events[index].event = updatedEventData;
      notifyListeners();
    }
  }

  // method to update note
  void updateNote(String eventId, String note) {
    final index = _events.indexWhere((element) => element.id == eventId);

    _events[index].note = note;
    notifyListeners();
  }

  // method to update a streak if the task is completed within a day
  void updateStreak(String eventId) {
    final today = DateTime.now();

    final index = _events.indexWhere((element) => element.id == eventId);

    final event = _events[index];

    if (event.lastCompletedDate != null) {
      final differenceInDays =
          today.difference(event.lastCompletedDate!).inDays;

      if (differenceInDays == 1) {
        event.dayStreak++;
      } else if (differenceInDays > 1) {
        event.dayStreak = 0;
      }

      if (event.dayStreak >= daysInMonth(today)) {
        event.monthStreak++;

        if (event.monthStreak >= 12) {
          event.yearStreak++;
        }
      }
    } else {
      event.dayStreak = 1;
    }

    event.lastCompletedDate = today;

    notifyListeners();
  }

// function to find days in month
  int daysInMonth(DateTime date) {
    var beginningNextMonth = (date.month < 12)
        ? DateTime(date.year, date.month + 1, 1)
        : DateTime(date.year + 1, 1, 1);
    return beginningNextMonth.subtract(Duration(days: 1)).day;
  }

  // method to archive note
  void archiveNote(String eventId) {
    final index = _events.indexWhere((element) => element.id == eventId);

    if (_events[index].isArchived == false) {
      _events[index].isArchived = true;
    }
    notifyListeners();
  }

  // method to unarchive note
  void unarchiveNote(String eventId) {
    final index = _events.indexWhere((element) => element.id == eventId);

    if (_events[index].isArchived == true) {
      _events[index].isArchived = false;
    }
    notifyListeners();
  }
}
