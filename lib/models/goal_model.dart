import 'package:cloud_firestore/cloud_firestore.dart';

//Model class representing a Goal.
class Goal {
  final String id;
  final String title;
  final String category;
  final String note;
  final DateTime? startDate;
  final DateTime? endDate;
  final Timestamp createdAt;

  //Constructor for the Goal class.
  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.note,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  //Factory constructor to create a Goal instance from a Firestore document.
  factory Goal.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      note: data['note'] ?? '',
      startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null,
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  //Converts the Goal instance to a Map (useful for Firestore operations).
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'note': note,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'createdAt': createdAt,
    };
  }
}