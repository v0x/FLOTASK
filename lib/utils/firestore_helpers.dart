import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateRecurrenceStatus({
  required DocumentReference recurrenceRef,
  required DocumentReference taskRef,
  required DocumentReference goalRef,
  required bool isCompleted,
}) async {
  // Update the specific recurrence's status
  await recurrenceRef.update({'status': isCompleted ? 'completed' : 'todo'});

  // Fetch the current count of completed recurrences
  final taskSnapshot = await taskRef.get();
  int totalCompletedRecurrences =
      taskSnapshot['totalCompletedRecurrences'] ?? 0;

  // Adjust the count based on the action (increment if completed, decrement if undone)
  totalCompletedRecurrences += isCompleted ? 1 : -1;

  // Update the task with the new total of completed recurrences
  await taskRef.update({
    'totalCompletedRecurrences': totalCompletedRecurrences,
  });

  // Fetch and update the goal's totalTaskCompletedRecurrences
  final goalSnapshot = await goalRef.get();
  int totalTaskCompletedRecurrences =
      goalSnapshot['totalTaskCompletedRecurrences'] ?? 0;

  totalTaskCompletedRecurrences += isCompleted ? 1 : -1;

  // Update the goal's completed recurrences count
  await goalRef.update({
    'totalTaskCompletedRecurrences': totalTaskCompletedRecurrences,
  });
}
