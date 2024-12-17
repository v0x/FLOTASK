import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_goal.dart';
import 'package:flotask/utils/firestore_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyTaskPage extends StatefulWidget {
  const DailyTaskPage({super.key});

  @override
  _DailyTaskPageState createState() => _DailyTaskPageState();
}

class _DailyTaskPageState extends State<DailyTaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPriority = 'All'; // Priority filter

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
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in'));
    }

    final String userId = currentUser.uid;
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

                final tasks = taskSnapshot.data!.docs.where((task) {
                  final taskData = task.data() as Map<String, dynamic>? ?? {};
                  final taskPriority = taskData['tag'] ?? 'No tags';
                  return _selectedPriority == 'All' || taskPriority == _selectedPriority;
                }).toList();

                if (tasks.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: tasks.map((task) {
                    final taskData = task.data() as Map<String, dynamic>? ?? {};
                    String taskName = taskData['task'] ?? 'Unnamed Task';
                    String goalName = goal['title'] ?? 'Unnamed Goal';
                    String priorityTag = taskData['tag'] ?? 'No tags';

                    Map<String, Color> priorityColors = {
                      'No tags': Colors.grey,
                      'Low': Colors.green,
                      'Medium': Colors.orange,
                      'High': Colors.red,
                    };

                    return StreamBuilder<QuerySnapshot>(
                      stream: task.reference
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
                            final recurrenceData =
                                recurrence.data() as Map<String, dynamic>;
                            bool isCompleted =
                                recurrenceData['status'] == 'completed';

                            return ListTile(
                              onLongPress: () async {
                                if (status == 'paused') {
                                  await recurrence.reference
                                      .update({'status': 'todo'});
                                } else {
                                  await recurrence.reference
                                      .update({'status': 'paused'});
                                }
                                setState(() {});
                              },
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: priorityColors[priorityTag],
                                    size: 12,
                                  ),
                                  Checkbox(
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
                                ],
                              ),
                              title: Text(taskName),
                              subtitle: Text(
                                  'Goal: $goalName\nPriority: $priorityTag\nDate: ${_formatDate((taskData['startDate'] as Timestamp).toDate())} to ${_formatDate((taskData['endDate'] as Timestamp).toDate())}\nTime: ${taskData['selectedTime'] ?? 'Any time'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editTask(
                                          task.reference,
                                          taskData);
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
  }

  Future<void> _editTask(
      DocumentReference taskRef, Map<String, dynamic> currentTaskData) async {
    final TextEditingController _taskController =
        TextEditingController(text: currentTaskData['task'] ?? '');
    String _priorityTag = currentTaskData['tag'] ?? 'No tags';
    final List<Map<String, dynamic>> _priorityOptions = [
      {'label': 'No tags', 'color': Colors.grey},
      {'label': 'Low', 'color': Colors.green},
      {'label': 'Medium', 'color': Colors.orange},
      {'label': 'High', 'color': Colors.red},
    ];

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
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Priority:'),
                        DropdownButton<String>(
                          value: _priorityTag,
                          items: _priorityOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['label'],
                              child: Text(
                                option['label'],
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _priorityTag = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await taskRef.update({
                      'task': _taskController.text,
                      'tag': _priorityTag,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Daily tasks",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Filter by Priority: "),
                DropdownButton<String>(
                  value: _selectedPriority,
                  items: ['All', 'High', 'Medium', 'Low', 'No tags']
                      .map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList('todo'),
                _buildTaskList('completed'),
                _buildTaskList('paused'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalPage()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
