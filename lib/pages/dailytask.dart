import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_goal.dart';
import 'package:flotask/utils/firestore_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Three tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateRecurrenceStatus(
      DocumentReference recurrenceRef,
      DocumentReference taskRef,
      DocumentReference goalRef,
      bool isCompleted) async {
    await updateRecurrenceStatus(
      recurrenceRef: recurrenceRef,
      taskRef: taskRef,
      goalRef: goalRef,
      isCompleted: isCompleted,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _buildTaskList(String status) {
    final today = _formatDate(DateTime.now());
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: Text('Please log in.'));
        }

        final String userId = userSnapshot.data!.uid;

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

            final goals = snapshot.data!.docs;
            List<Widget> taskWidgets = [];

            for (var goal in goals) {
              taskWidgets.add(
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('goals')
                      .doc(goal.id)
                      .collection('tasks')
                      .snapshots(),
                  builder: (context, taskSnapshot) {
                    if (!taskSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final tasks = taskSnapshot.data!.docs;
                    if (tasks.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: tasks.map((task) {
                        String taskName = task['task'];
                        String goalName = goal['title'];

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('goals')
                              .doc(goal.id)
                              .collection('tasks')
                              .doc(task.id)
                              .collection('recurrences')
                              .where('status', isEqualTo: status)
                              .where('date', isEqualTo: DateTime.parse(today))
                              .snapshots(),
                          builder: (context, recurrenceSnapshot) {
                            if (!recurrenceSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            final recurrences = recurrenceSnapshot.data!.docs;

                            if (recurrences.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: recurrences.map((recurrence) {
                                bool isCompleted =
                                    recurrence['status'] == 'completed';

                                return ListTile(
                                  onLongPress: () async {
                                    if (status == 'paused') {
                                      await recurrence.reference.update({'status': 'todo'});
                                    } else {
                                      await recurrence.reference.update({'status': 'paused'});
                                    }
                                    setState(() {});
                                  },
                                  leading: Checkbox(
                                    value: isCompleted,
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        _updateRecurrenceStatus(
                                          recurrence.reference,
                                          task.reference,
                                          goal.reference,
                                          value,
                                        );
                                      }
                                    },
                                  ),
                                  title: Text(taskName),
                                  subtitle: Text(
                                      'Goal: $goalName\nDate: ${_formatDate((task['startDate'] as Timestamp).toDate())} to ${_formatDate((task['endDate'] as Timestamp).toDate())}\nTime: ${task['selectedTime'] ?? 'Any time'}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          _editTask(
                                              task.reference,
                                              task.data()
                                                  as Map<String, dynamic>);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              );
            }

            if (taskWidgets.isEmpty) {
              return const Center(child: Text('No tasks for today.'));
            }

            return ListView(children: taskWidgets);
          },
        );
      },
    );
  }

  Future<void> _editTask(
      DocumentReference taskRef, Map<String, dynamic> currentTaskData) async {
    final TextEditingController _taskController =
        TextEditingController(text: currentTaskData['task']);
    TimeOfDay? _selectedTime = currentTaskData['selectedTime'] != null
        ? TimeOfDay(
            hour: int.parse(currentTaskData['selectedTime'].split(":")[0]),
            minute: int.parse(currentTaskData['selectedTime'].split(":")[1]),
          )
        : null;
    String _selectedOption =
        _selectedTime != null ? 'Specific time' : 'Any time';

    Future<void> _selectTime(BuildContext context, StateSetter setState) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime ??
            TimeOfDay.now(), // Default to current time if none selected
      );
      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked; // Update the selected time
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Time',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Time:'),
                        DropdownButton<String>(
                          value: _selectedOption,
                          items: <String>['Any time', 'Specific time']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedOption = newValue!;
                              if (newValue == 'Specific time') {
                                _selectTime(context, setState);
                              } else {
                                _selectedTime = null;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_selectedOption == 'Specific time' &&
                        _selectedTime != null)
                      Text('Selected Time: ${_selectedTime!.format(context)}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _deleteTask(taskRef);
                  },
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await taskRef.update({
                      'task': _taskController.text,
                      'selectedTime': _selectedTime != null
                          ? '${_selectedTime!.hour}:${_selectedTime!.minute}'
                          : null,
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTask(DocumentReference taskRef) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await taskRef.delete();
                Navigator.of(context).pop(); // Close the confirmation dialog
                Navigator.of(context).pop(); // Close the edit dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Daily tasks",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFEBEAE3),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'To-do'),
            Tab(text: 'Completed'),
            Tab(text: 'Paused'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList('todo'),
          _buildTaskList('completed'),
          _buildTaskList('paused'),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddGoalPage()),
            );
          },
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
