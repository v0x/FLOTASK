import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'event_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// the global state for handling all events within our app
class EventProvider extends ChangeNotifier {
  // List of events
  List<EventModel> _events = [];

  // Get the list of events
  List<EventModel> get events => _events;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load events from Firebase
  Future<void> loadEventsFromFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('events').get();

      _events = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Create EventModel from Firebase data with null checks
        return EventModel(
          id: doc.id,
          event: CalendarEventData(
            title: data['title'] as String? ?? 'Untitled Event',
            date: data['startDate'] != null
                ? DateTime.parse(data['startDate'] as String)
                : DateTime.now(),
            endDate: data['endDate'] != null
                ? DateTime.parse(data['endDate'] as String)
                : null,
            startTime: data['startTime'] != null
                ? DateTime.parse(data['startTime'] as String)
                : null,
            endTime: data['endTime'] != null
                ? DateTime.parse(data['endTime'] as String)
                : null,
          ),
          note: data['note'] as String? ?? '',
          isRecurring: data['isRecurring'] as bool? ?? false,
          isCompleted: data['isCompleted'] as bool? ?? false,
          dayStreak: data['dayStreak'] as int? ?? 0,
          monthStreak: data['monthStreak'] as int? ?? 0,
          yearStreak: data['yearStreak'] as int? ?? 0,
          isArchived: data['isArchived'] as bool? ?? false,
          tags: List<String>.from(data['tags'] ?? []),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading events from Firebase: $e');
    }
  }

  // Method to add a new event
  Future<void> addEvent(CalendarEventData eventData,
      {String? note, List<String>? tags, bool? isRecurring}) async {
    final newEvent = EventModel(
        event: eventData, note: note, tags: tags, isRecurring: isRecurring!);

// Save the event to Firestore
    DocumentReference docRef = await _firestore.collection('events').add({
      // 'id': newEvent.event.hashCode,
      'title': newEvent.event.title,
      'description': newEvent.event.description,
      'startDate': newEvent.event.date.toIso8601String(),
      'endDate': newEvent.event.endDate.toIso8601String(),
      'startTime': newEvent.event.startTime?.toIso8601String(),
      'endTime': newEvent.event.endTime?.toIso8601String(),
      'isRecurring': newEvent.isRecurring,
      'isCompleted': newEvent.isCompleted,
      'dayStreak': newEvent.dayStreak,
      'monthStreak': newEvent.monthStreak,
      'yearStreak': newEvent.yearStreak,
      'isArchived': newEvent.isArchived,
      'note': newEvent.note,
      'tags': newEvent.tags
    });

    newEvent.id = docRef.id;

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
  Future<void> updateNote(String eventId, String note) async {
    final index = _events.indexWhere((element) => element.id == eventId);

    _events[index].note = note;
    notifyListeners();

    // update note in firebase now
    if (_events[index].id != null) {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(_events[index].id)
          .update({'note': note});
    } else {
      print('Error: Firebase ID is null for event ${_events[index].id}');
    }
  }

  // method to update a streak if the task is completed within a day, then streak of a month and year
  Future<void> updateStreak(String eventId) async {
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

      if (event.dayStreak >= 30) {
        event.monthStreak++;

        if (event.monthStreak >= 12) {
          event.yearStreak++;
        }
      }
    } else {
      event.dayStreak = 1;
    }

    event.lastCompletedDate = today;

    await FirebaseFirestore.instance.collection('events').doc(event.id).update({
      'dayStreak': event.dayStreak,
      'monthStreak': event.monthStreak,
      'yearStreak': event.yearStreak
    });

    notifyListeners();
  }

// function to find days in month
  // int daysInMonth(DateTime date) {
  //   var beginningNextMonth = (date.month < 12)
  //       ? DateTime(date.year, date.month + 1, 1)
  //       : DateTime(date.year + 1, 1, 1);
  //   return beginningNextMonth.subtract(Duration(days: 1)).day;
  // }

  // method to archive note
  // Future<void> archiveNote(String eventId) async {
  //   final index = _events.indexWhere((element) => element.id == eventId);

  //   if (_events[index].isArchived == false) {
  //     _events[index].isArchived = true;
  //   }

  //   await FirebaseFirestore.instance
  //       .collection('events')
  //       .doc(_events[index].id)
  //       .update({'isCompleted': _events[index].isArchived});
  //   notifyListeners();
  // }

  // // method to unarchive note
  // Future<void> unarchiveNote(String eventId) async {
  //   final index = _events.indexWhere((element) => element.id == eventId);

  //   if (_events[index].isArchived == true) {
  //     _events[index].isArchived = false;
  //   }
  //   notifyListeners();

  //   await FirebaseFirestore.instance
  //       .collection('events')
  //       .doc(_events[index].id)
  //       .update({'isCompleted': _events[index].isArchived});
  // }

  Future<void> updateArchivedStatus(String eventId, bool isArchived) async {
    final index = _events.indexWhere((element) => element.id == eventId);

    if (index != -1) {
      _events[index].isArchived = !isArchived;

      // Update archived status in Firebase
      if (_events[index].id != null) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(_events[index].id)
            .update({'isArchived': _events[index].isArchived});
      } else {
        print('Error: Firebase ID is null for event ${_events[index].id}');
      }
    } else {
      print('Error: Event not found with id $eventId');
    }

    notifyListeners();
  }

  Future<void> toggleComplete(String eventId, bool value) async {
    final index = _events.indexWhere((element) => element.id == eventId);
    final event = _events[index];

    // Check if we are completing or undoing a task
    if (value == true) {
      event.isCompleted = true;
      updateStreak(event.id!);
    } else {
      // If unchecking, undo the completion and reduce the streak
      event.isCompleted = false;

      if (event.lastCompletedDate != null) {
        final today = DateTime.now();
        final differenceInDays =
            today.difference(event.lastCompletedDate!).inDays;

        // Check if we need to roll back the streak (only if the task was completed today)
        if (differenceInDays == 0) {
          // Reduce day streak
          event.dayStreak = event.dayStreak > 0 ? event.dayStreak - 1 : 0;

          // If day streak reaches below days in month, adjust the month streak
          // if (event.dayStreak < 30 && event.monthStreak > 0) {
          //   event.monthStreak--;

          //   // If month streak is undone, adjust the year streak if necessary
          //   if (event.monthStreak < 12 && event.yearStreak > 0) {
          //     event.yearStreak--;
          //   }
          // }

          // Set last completed date to null to indicate it's undone
          event.lastCompletedDate = null;
        }
      }
    }

    await FirebaseFirestore.instance.collection('events').doc(event.id).update({
      'isCompleted': event.isCompleted,
      'dayStreak': event.dayStreak,
      'monthStreak': event.monthStreak,
      'yearStreak': event.yearStreak
    });

    notifyListeners();
  }
}
