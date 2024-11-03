import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  // Function to format the date
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date); // Format the date
  }

  // Function to build the list of tasks for a goal
  Widget _buildTaskList(DocumentSnapshot goal) {
    return StreamBuilder<QuerySnapshot>(
      stream: goal.reference.collection('tasks').snapshots(),
      builder: (context, taskSnapshot) {
        if (!taskSnapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final tasks = taskSnapshot.data!.docs;
        if (tasks.isEmpty) {
          return const Text('No tasks added yet.');
        }

        // Calculate task progress
        int completedTasks =
            tasks.where((task) => task['status'] == 'completed').length;
        double taskProgress = completedTasks / tasks.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: taskProgress), // Progress bar
            Text(
                '${(taskProgress * 100).toStringAsFixed(0)}% completed'), // Percentage text
            const SizedBox(height: 10),
            ...tasks.map((task) {
              String taskStartDate = _formatDate(task['startDate']);
              String taskEndDate = _formatDate(task['endDate']);
              bool isCompleted = task['status'] == 'completed';

              return ListTile(
                title: Text(
                  task['task'],
                  style: TextStyle(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  'Repeat every: ${task['repeatInterval']} days\nDate: $taskStartDate to $taskEndDate',
                ),
                trailing: Checkbox(
                  value: isCompleted,
                  onChanged: (bool? newValue) {
                    task.reference.update(
                        {'status': newValue == true ? 'completed' : 'todo'});
                  },
                ),
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

              // Format the start and end dates for the goal
              String goalStartDate = _formatDate(goal['startDate']);
              String goalEndDate = _formatDate(goal['endDate']);

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
