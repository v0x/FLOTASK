import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:calendar_view/calendar_view.dart';
import 'event_model.dart';

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
    notifyListeners(); // Notify the UI that the event list has changed
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
}
