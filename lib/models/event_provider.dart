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
        event.streak++;
      } else if (differenceInDays > 1) {
        event.streak = 0;
      }

      // Check if a new month is reached
      if (isNewMonth(event.lastCompletedDate!, today)) {
        print("New month milestone reached!");

        // display widget
      }

      // display yearly flair
      if (isNewYear(event.lastCompletedDate!, today)) {
        print("New yearly milestone reached!");
      }
    } else {
      event.streak = 1;
    }

    event.lastCompletedDate = today;
  }

// add new flair if a new motnh has been reached
  bool isNewMonth(DateTime lastCompletedDate, DateTime currentDate) {
    return (currentDate.year > lastCompletedDate.year) ||
        (currentDate.year == lastCompletedDate.year &&
            currentDate.month > lastCompletedDate.month);
  }

// add new flair if new year has been reached
  bool isNewYear(DateTime lastCompletedDate, DateTime currentDate) {
    return currentDate.year > lastCompletedDate.year;
  }

  Widget displayFlair(int streakCount, DateTime lastCompletedDate) {
    final today = DateTime.now();

    // Check for yearly flair
    if (isNewYear(lastCompletedDate, today)) {
      return Icon(Icons.cake, color: Colors.amber); // Yearly milestone flair
    }

    // Check for monthly flair
    if (isNewMonth(lastCompletedDate, today)) {
      return Icon(Icons.calendar_today,
          color: Colors.purple); // Monthly milestone flair
    }

    // Display daily flair based on streak count
    if (streakCount >= 7) {
      return Icon(Icons.whatshot, color: Colors.red); // Weekly streak flair
    }

    return SizedBox(); // No flair for small streaks
  }
}
