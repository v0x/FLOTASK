// goal_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

//A service class to handle Firestore interactions related to Goals.
class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Retrieves all goals for the current user as a Future.
  Future<List<Goal>> getGoals() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Goal.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching goals: $e');
      return [];
    }
  }

  //Streams all goals for the current user in real-time.
  Stream<List<Goal>> streamGoals() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Goal.fromDocument(doc)).toList();
    }).handleError((error) {
      print('Error streaming goals: $error');
    });
  }
}
