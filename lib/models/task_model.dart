import 'package:cloud_firestore/cloud_firestore.dart';

//A model class representing a Task. Very cool. 
class Task {
  final String id;
  final String taskName;
  final int repeatInterval;
  final DateTime startDate;
  final DateTime endDate;
  final String? selectedTime; //Format: 'HH:mm'
  final int workTime;
  final int breakTime; 
  final String taskColor; //Stored as a hex string, e.g., 'FF5733'
  final String status;
  final int totalRecurrences;
  final int totalCompletedRecurrences;

  //Constructor for the Task class. WOAHHHHHHHHHHHHH
  Task({
    required this.id,
    required this.taskName,
    required this.repeatInterval,
    required this.startDate,
    required this.endDate,
    this.selectedTime,
    required this.workTime,
    required this.breakTime,
    required this.taskColor,
    required this.status,
    required this.totalRecurrences,
    required this.totalCompletedRecurrences,
  });

  //Factory constructor to create a Task instance from a Firestore document.
  factory Task.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    //Handle taskColor to ensure it has 8 characters (ARGB)
    String color = data['color'] ?? 'FF5733';
    if (color.length == 6) {
      color = 'FF$color'; //Add default alpha value if not provided
    }

    return Task(
      id: doc.id,
      taskName: data['task'] ?? '',
      repeatInterval: data['repeatInterval'] ?? 1,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      selectedTime: data['selectedTime'],
      workTime: data['workTime'] ?? 0,
      breakTime: data['breakTime'] ?? 0,
      taskColor: color.toUpperCase(),
      status: data['status'] ?? 'todo',
      totalRecurrences: data['totalRecurrences'] ?? 0,
      totalCompletedRecurrences: data['totalCompletedRecurrences'] ?? 0,
    );
  }

  //Converts the Task instance to a Map (useful if needed). very cool ik.
  Map<String, dynamic> toMap() {
    return {
      'task': taskName,
      'repeatInterval': repeatInterval,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'selectedTime': selectedTime,
      'workTime': workTime,
      'breakTime': breakTime,
      'color': taskColor,
      'status': status,
      'totalRecurrences': totalRecurrences,
      'totalCompletedRecurrences': totalCompletedRecurrences,
    };
  }
}
