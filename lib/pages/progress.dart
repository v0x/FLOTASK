import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tasklist.dart'; // Import TaskListPage
import 'package:intl/intl.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TextEditingController _searchController =
      TextEditingController(); //search bar WR4
  String _searchQuery = ''; //search bar WR4

  //function to format DateTime as a string
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

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
      try {
        //fatch and delete all tasks in the goal
        final taskCollection = goalRef.collection('tasks');
        final taskSnapshots = await taskCollection.get();
        if (taskSnapshots.docs.isNotEmpty) {
          for (final task in taskSnapshots.docs) {
            //fatch and delete all recurrences in rach task
            final recurrenceCollection =
                task.reference.collection('recurrences');
            final recurrenceSnapshots = await recurrenceCollection.get();
            for (final recurrence in recurrenceSnapshots.docs) {
              await recurrence.reference.delete(); //delete recurrences
            }
            await task.reference
                .delete(); //delete tasks after deleting recurrences
          }
        }

        await goalRef.delete(); //delete the goal itself

        //display a success message of deleting goals
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal deleted successfully')),
        );
      } catch (e) {
        //handle any errors that occur during deletion
        print('error deleting goal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete goal: $e')),
        );
      }
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
            controller: _searchController, //search bar WR4
            decoration: const InputDecoration(
              //search bar WR4//search bar WR4
              hintText: 'Search by goal title or category or note...',
              border: OutlineInputBorder(), //search bar WR4
              prefixIcon: Icon(Icons.search), //search bar WR4
            ),
            onChanged: (value) {
              //search bar WR4
              setState(() {
                //search bar WR4
                _searchQuery = value.toLowerCase(); //search bar WR4
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('goals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator()); //show loading indicator
          }

          final goals = snapshot.data!.docs.where((goal) {
            //search bar WR4
            //filter goals based on the search query
            final title =
                (goal['title'] ?? '').toString().toLowerCase(); //search bar WR4
            final category = (goal['category'] ?? '')
                .toString()
                .toLowerCase(); //search bar WR4
            final note = (goal['note'] ?? '').toString().toLowerCase();
            return title.contains(_searchQuery) ||
                category.contains(_searchQuery) ||
                note.contains(_searchQuery); //search bar WR4
          }).toList();

          if (goals.isEmpty) {
            return const Center(child: Text('No goals created yet.'));
          }

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final goalRef = goal.reference;

              //calculate goal progress based on completed and toatl recurrences
              final int totalTaskCompletedRecurrences =
                  goal['totalTaskCompletedRecurrences'] ?? 0;
              final int totalTaskRecurrences =
                  goal['totalTaskRecurrences'] ?? 0;
              final double goalProgress = totalTaskRecurrences > 0
                  ? totalTaskCompletedRecurrences / totalTaskRecurrences
                  : 0;
              //format start and end dates for display
              final String goalStartDate =
                  _formatDate((goal['startDate'] as Timestamp).toDate());
              final String goalEndDate =
                  _formatDate((goal['endDate'] as Timestamp).toDate());

              return ListTile(
                //goal with edit icon
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(goal['title']),
                    IconButton(
                      icon: const Icon(Icons.edit), // Edit icon
                      onPressed: () => _editGoal(context, goalRef,
                          goal.data() as Map<String, dynamic>),
                    ),
                  ],
                ),
                //showing goal details and progress bar
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
                //tap to naviagte to the Tasklist
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
