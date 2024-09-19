import 'package:calendar_view/calendar_view.dart';
import 'package:uuid/uuid.dart';

// Model class for a user-created event
class EventModel {
  final String id;
  CalendarEventData event;
  String? note;
  List<String>? tags;
  String? category;
  bool isCompleted;
  int streak;

  EventModel({
    required this.event,
    this.note,
    this.tags,
    this.category = "Home",
    this.isCompleted = false,
    this.streak = 0,
  }) : id = Uuid().v4(); // Unique ID for each event
}
