import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tasklist.dart'; // Import TaskListPage

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  // Function to edit a goal
  Future<void> _editGoal(BuildContext context, DocumentReference goalRef,
      Map<String, dynamic> currentGoalData) async {
    // Create controllers with current goal values
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
                  // Goal Name Input
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Name',
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Category Input
                  TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Note Input
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      await _deleteGoal(
                          context, goalRef); // Delete the goal if user confirms
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cancel and close dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Update goal data in Firestore
                      await goalRef.update({
                        'title': _nameController.text,
                        'category': _categoryController.text,
                        'note': _noteController.text,
                      });
                      Navigator.of(context)
                          .pop(); // Close dialog after saving changes
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              )
            ]);
      },
    );
  }

  // Function to delete a goal and its associated tasks
  Future<void> _deleteGoal(
      BuildContext context, DocumentReference goalRef) async {
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

              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(goal['title']),
                    IconButton(
                      icon: const Icon(Icons.edit), // Edit icon
                      onPressed: () => _editGoal(context, goal.reference,
                          goal.data() as Map<String, dynamic>),
                    ),
                  ],
                ),
                subtitle:
                    Text('Category: ${goal['category'] ?? 'No category'}\n'
                        'Note: ${goal['note'] ?? 'No note'}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskListPage(goal: goal),
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
