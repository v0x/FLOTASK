import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flotask/utils/firestore_helpers.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  // Function to format the date
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Function to build the list of recurring dates for a task
  Widget _buildRecurringDateList(
      DocumentReference taskRef, DocumentReference goalRef) {
    return StreamBuilder<QuerySnapshot>(
      stream: taskRef.collection('recurrences').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final recurrences = snapshot.data!.docs;
        if (recurrences.isEmpty) {
          return const Text('No recurring dates yet.');
        }

        //sort the recurrencies by ascending order of date
        final sortedRecurrences = recurrences
          ..sort((a, b) {
            final dateA = (a['date'] as Timestamp).toDate();
            final dateB = (b['date'] as Timestamp).toDate();
            return dateA.compareTo(dateB);
          });

        int completedCount = sortedRecurrences
            .where((doc) => doc['status'] == 'completed')
            .length;
        double taskProgress = sortedRecurrences.isNotEmpty
            ? completedCount / sortedRecurrences.length
            : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: taskProgress),
            Text(
                '${(taskProgress * 100).toStringAsFixed(0)}% of task completed'),
            const SizedBox(height: 10),
            ...sortedRecurrences.map((recurrence) {
              bool isCompleted = recurrence['status'] == 'completed';
              String date =
                  _formatDate((recurrence['date'] as Timestamp).toDate());

              return ListTile(
                title: Text('Date: $date'),
                trailing: Checkbox(
                  value: isCompleted,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      updateRecurrenceStatus(
                        recurrenceRef: recurrence.reference,
                        taskRef: taskRef,
                        goalRef: goalRef,
                        isCompleted: newValue,
                      );
                    }
                  },
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // Function to build the list of tasks for a goal and calculate goal progress
  Widget _buildTaskList(DocumentSnapshot goal) {
    final goalRef = goal.reference;

    return StreamBuilder<QuerySnapshot>(
      stream: goalRef.collection('tasks').snapshots(),
      builder: (context, taskSnapshot) {
        if (!taskSnapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final tasks = taskSnapshot.data!.docs;
        if (tasks.isEmpty) {
          return const Text('No tasks added yet.');
        }

        int totalTaskCompletedRecurrences =
            goal['totalTaskCompletedRecurrences'] ?? 0;
        int totalTaskRecurrences =
            goal['totalTaskRecurrences'] ?? 0; // Prevent division by zero
        double goalProgress = totalTaskRecurrences > 0
            ? totalTaskCompletedRecurrences / totalTaskRecurrences
            : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: goalProgress),
            Text(
                '${(goalProgress * 100).toStringAsFixed(0)}% of goal completed'),
            const SizedBox(height: 10),
            ...tasks.map((task) {
              String taskStartDate =
                  _formatDate((task['startDate'] as Timestamp).toDate());
              String taskEndDate =
                  _formatDate((task['endDate'] as Timestamp).toDate());

              return ExpansionTile(
                title: Text(task['task']),
                subtitle: Text('Date: $taskStartDate to $taskEndDate'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildRecurringDateList(task.reference, goalRef),
                  ),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        backgroundColor: const Color(0xFFEBEAE3),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('goals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data!.docs;

          if (goals.isEmpty) {
            return const Center(child: Text('No goals created yet.'));
          }

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              String goalStartDate =
                  _formatDate((goal['startDate'] as Timestamp).toDate());
              String goalEndDate =
                  _formatDate((goal['endDate'] as Timestamp).toDate());

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(goal['title']),
                  subtitle: Text(
                    'Category: ${goal['category'] ?? 'No category'}\n'
                    'Date: $goalStartDate to $goalEndDate',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildTaskList(goal),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
