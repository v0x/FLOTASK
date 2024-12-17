import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

//A service class to handle Firestore interactions related to Tasks.
class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* Retrieves all tasks for a given goal as a list.
  * [goalRef]: The DocumentReference of the goal.
  * Returns a Future that resolves to a List of Task objects. */
  Future<List<Task>> getTasksForGoal(DocumentReference goalRef) async {
    try {
      QuerySnapshot snapshot = await goalRef.collection('tasks').get();

      return snapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  /* Retrieves all tasks for a given goal as a stream.
  *
  * [goalRef]: The DocumentReference of the goal.
  * Returns a Stream of Lists of Task objects. */
  Stream<List<Task>> streamTasksForGoal(DocumentReference goalRef) {
    return goalRef.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
    }).handleError((error) {
      print('Error streaming tasks: $error');
    });
  }

  /* Retrieves a single task by its ID for a given goal.
  * [goalRef]: The DocumentReference of the goal.
  * [taskId]: The ID of the task.
  * Returns a Future that resolves to a Task object or null if not found. */
  Future<Task?> getTaskById(DocumentReference goalRef, String taskId) async {
    try {
      DocumentSnapshot doc = await goalRef.collection('tasks').doc(taskId).get();

      if (doc.exists) {
        return Task.fromDocument(doc);
      } else {
        print('Task with ID $taskId does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching task by ID: $e');
      return null;
    }
  }
}
