import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'event_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// the global state for handling all firebase events within our app
class EventProvider extends ChangeNotifier {
  // List of events
  List<EventModel> _events = [];

  // Get the list of events
  List<EventModel> get events => _events;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get reference to user's events collection
  CollectionReference get userEventsRef =>
      _firestore.collection('users').doc(currentUserId).collection('events');

  // Load events from Firebase
  Future<void> loadEventsFromFirebase() async {
    try {
      if (currentUserId == null) return;

      QuerySnapshot snapshot = await userEventsRef.get();

      _events = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return EventModel(
          id: doc.id,
          ref: doc.reference,
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
      print('Error loading events: $e');
      throw e;
    }
  }

  // Method to add a new event with calendar data from calendar view, note, tags, voice memos, reucurring tasks
  Future<void> addEvent(CalendarEventData eventData,
      {String? note,
      List<String>? tags,
      bool? isRecurring,
      String? voiceMemos}) async {
    if (currentUserId == null) return;

    final newEvent = EventModel(
      event: eventData,
      note: note,
      tags: tags,
      isRecurring: isRecurring!,
      voiceMemos: voiceMemos,
    );

// Save the event to Firestore
    DocumentReference docRef = await userEventsRef.add({
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
      'tags': newEvent.tags,
      'voiceMemos': newEvent.voiceMemos
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
    try {
      if (currentUserId == null) return;

      await userEventsRef.doc(eventId).update({'note': note});

      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index].note = note;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating note: $e');
      throw e;
    }
  }

  // method to update a streak if the task is completed within a day, then streak of a month and year
  Future<void> updateStreak(String eventId) async {
    final today = DateTime.now();
    final index = _events.indexWhere((element) => element.id == eventId);
    final event = _events[index];

    // if the task has been completed before, check if the difference in days is 1 day
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

    await userEventsRef.doc(event.id).update({
      'dayStreak': event.dayStreak,
      'monthStreak': event.monthStreak,
      'yearStreak': event.yearStreak,
      'lastCompletedDate': event.lastCompletedDate?.toIso8601String()
    });

    notifyListeners();
  }

  // method to update archived status
  Future<void> updateArchivedStatus(String eventId, bool isArchived) async {
    if (currentUserId == null) return;

    final index = _events.indexWhere((element) => element.id == eventId);

    if (index != -1) {
      _events[index].isArchived = !isArchived;

      // Update archived status in Firebase using userEventsRef
      try {
        await userEventsRef
            .doc(eventId)
            .update({'isArchived': _events[index].isArchived});
        notifyListeners();
      } catch (e) {
        print('Error updating archived status: $e');
        // Revert the local change if the Firebase update fails
        _events[index].isArchived = isArchived;
        notifyListeners();
        throw e;
      }
    } else {
      print('Error: Event not found with id $eventId');
    }

    notifyListeners();
  }

  Future<void> toggleComplete(String eventId, bool value) async {
    if (currentUserId == null) return;

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

        // if the task was completed today, reduce the day streak
        if (differenceInDays == 0) {
          // Reduce day streak
          event.dayStreak = event.dayStreak > 0 ? event.dayStreak - 1 : 0;

          // Set last completed date to null to indicate it's undone
          event.lastCompletedDate = null;
        }
      }
    }

    // Update in Firestore using userEventsRef instead of direct collection reference
    await userEventsRef.doc(event.id).update({
      'isCompleted': event.isCompleted,
      'dayStreak': event.dayStreak,
      'monthStreak': event.monthStreak,
      'yearStreak': event.yearStreak,
      'lastCompletedDate': event.lastCompletedDate?.toIso8601String()
    });

    notifyListeners();
  }

  Future<void> saveMemo(String eventId, String text) async {
    final index = _events.indexWhere((element) => element.id == eventId);
    final event = _events[index];

    event.voiceMemos = text;

    await userEventsRef.doc(event.id).update({'voiceMemos': text});

    notifyListeners();
  }

  Future<void> updateEventDetails(
    String eventId, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    bool? isRecurring,
    String? voiceMemos,
  }) async {
    try {
      final docRef = userEventsRef.doc(eventId);

      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (startTime != null) updates['startTime'] = startTime.toIso8601String();
      if (endTime != null) updates['endTime'] = endTime.toIso8601String();
      if (description != null) updates['description'] = description;
      if (isRecurring != null) updates['isRecurring'] = isRecurring;
      if (voiceMemos != null) updates['voiceMemos'] = voiceMemos;

      await docRef.update(updates);

      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final event = _events[index];
        // Create new CalendarEventData with updated values
        final updatedEventData = CalendarEventData(
          title: title ?? event.event.title,
          date: event.event.date,
          endDate: event.event.endDate,
          startTime: startTime ?? event.event.startTime,
          endTime: endTime ?? event.event.endTime,
          description: description ?? event.event.description,
        );

        // Update the event with the new CalendarEventData
        _events[index] = EventModel(
          id: event.id,
          ref: event.ref,
          event: updatedEventData,
          note: event.note,
          tags: event.tags,
          category: event.category,
          isCompleted: event.isCompleted,
          dayStreak: event.dayStreak,
          monthStreak: event.monthStreak,
          yearStreak: event.yearStreak,
          isRecurring: isRecurring ?? event.isRecurring,
          isReminder: event.isReminder,
          lastCompletedDate: event.lastCompletedDate,
          isArchived: event.isArchived,
        );

        notifyListeners();
      }
    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
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
