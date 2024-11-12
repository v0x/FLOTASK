import 'package:calendar_view/calendar_view.dart';
import 'package:uuid/uuid.dart';

// Model class for a user-created event; used globally for every feature
class EventModel {
  final String id;
  CalendarEventData event;
  String? note;
  List<String>? tags;
  String? category;
  bool isCompleted;
  int streak;
  bool isArchived;

  EventModel(
      {required this.event,
      this.note,
      this.tags,
      this.category = "Home",
      this.isCompleted = false,
      this.streak = 0,
      this.isArchived = false})
      : id = Uuid().v4();
}
