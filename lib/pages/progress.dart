import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tasklist.dart'; // Import TaskListPage
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressPage extends StatefulWidget {
  final Function(int) onGoalCompletion; // Callback to pass completed goals count

  const ProgressPage({super.key, required this.onGoalCompletion});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _previousCompletedGoals = -1;

  // Function to format DateTime as a string
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Function to calculate and update completed goals
  void _updateCompletedGoals(List<QueryDocumentSnapshot> goals) {
    int completedGoals = goals.where((goal) {
      int totalTaskCompletedRecurrences = goal['totalTaskCompletedRecurrences'] ?? 0;
      int totalTaskRecurrences = goal['totalTaskRecurrences'] ?? 0;

      return totalTaskRecurrences > 0 && totalTaskCompletedRecurrences == totalTaskRecurrences;
    }).length;

    print('DEBUG: Calculated Completed Goals = $completedGoals'); // Debugging

    if (completedGoals != _previousCompletedGoals) {
      _previousCompletedGoals = completedGoals;
      widget.onGoalCompletion(completedGoals);
      print('DEBUG: onGoalCompletion Callback Triggered with $completedGoals');
    }
  }

  // Function to edit a goal
  Future<void> _editGoal(BuildContext context, DocumentReference goalRef,
      Map<String, dynamic> currentGoalData) async {
    final TextEditingController _nameController =
        TextEditingController(text: currentGoalData['title']);
    final TextEditingController _categoryController =
        TextEditingController(text: currentGoalData['category']);
    final TextEditingController _noteController =
        TextEditingController(text: currentGoalData['note']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Goal'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _deleteGoal(context, goalRef);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await goalRef.update({
                  'title': _nameController.text,
                  'category': _categoryController.text,
                  'note': _noteController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGoal(BuildContext context, DocumentReference goalRef) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      final taskCollection = goalRef.collection('tasks');
      final tasks = await taskCollection.get();
      for (final task in tasks.docs) {
        await task.reference.delete();
      }
      await goalRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Page'),
        backgroundColor: const Color(0xFFEBEAE3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by goal title or category or note...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, usersnapshot) {
          if (!usersnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final String userId = usersnapshot.data!.uid;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('goals')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final goals = snapshot.data!.docs.where((goal) {
                final title = (goal['title'] ?? '').toString().toLowerCase();
                final category =
                    (goal['category'] ?? '').toString().toLowerCase();
                final note = (goal['note'] ?? '').toString().toLowerCase();
                return title.contains(_searchQuery) ||
                    category.contains(_searchQuery) ||
                    note.contains(_searchQuery);
              }).toList();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateCompletedGoals(goals); // Ensure proper timing
              });

              if (goals.isEmpty) {
                return const Center(child: Text('No goals created yet.'));
              }

              return ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  int totalTaskCompletedRecurrences =
                      goal['totalTaskCompletedRecurrences'] ?? 0;
                  int totalTaskRecurrences = goal['totalTaskRecurrences'] ?? 0;
                  double goalProgress = totalTaskRecurrences > 0
                      ? totalTaskCompletedRecurrences / totalTaskRecurrences
                      : 0;
                  String goalStartDate =
                      _formatDate((goal['startDate'] as Timestamp).toDate());
                  String goalEndDate =
                      _formatDate((goal['endDate'] as Timestamp).toDate());

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(goal['title']),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editGoal(context, goal.reference,
                              goal.data() as Map<String, dynamic>),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Category: ${goal['category'] ?? 'No category'}\nNote: ${goal['note'] ?? 'No note'}\nDate: $goalStartDate to $goalEndDate'),
                        LinearProgressIndicator(value: goalProgress),
                        Text(
                            '${(goalProgress * 100).toStringAsFixed(0)}% of goal completed'),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
