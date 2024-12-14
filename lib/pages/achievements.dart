import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/achievement_provider.dart';

class AchievementPage extends StatefulWidget {
  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  int totalCompletedTasks = 0;

  @override
  void initState() {
    super.initState();
    _fetchCompletedTasks();
  }

  Future<void> _fetchCompletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    int completedCount = 0;

    try {
      final goalsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Filter for logged-in user
          .collection('goals')
          .get();

      for (var goal in goalsSnapshot.docs) {
        final tasksSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .doc(goal.id)
            .collection('tasks')
            .get();

        for (var task in tasksSnapshot.docs) {
          final recurrencesSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('goals')
              .doc(goal.id)
              .collection('tasks')
              .doc(task.id)
              .collection('recurrences')
              .where('status', isEqualTo: 'completed') // Only count completed
              .get();

          completedCount += recurrencesSnapshot.docs.length;
        }
      }

      setState(() {
        totalCompletedTasks = completedCount - 1;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define milestones
    final List<int> milestones = [1, 5, 10, 15, 20, 25, 30, 35];

    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display total completed tasks
            if (totalCompletedTasks > 0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Completed Tasks: $totalCompletedTasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'You haven’t completed any tasks yet. Start completing tasks to see your achievements!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
        
            // Display milestone messages
            Expanded(
              child: ListView.builder(
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  final milestone = milestones[index];
                  final isAchieved = totalCompletedTasks >= milestone;

                  return ListTile(
                    leading: isAchieved
                        ? Icon(Icons.emoji_events, color: Colors.green)
                        : Icon(Icons.lock, color: Colors.red),
                    title: Text(
                      isAchieved
                          ? 'Congrats on milestone $milestone tasks!'
                          : 'Keep going for milestone $milestone tasks!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAchieved ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}