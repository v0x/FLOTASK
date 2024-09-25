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
