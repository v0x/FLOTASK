import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_task.dart'; // Import AddTaskPage for task adding functionality

class TaskListPage extends StatefulWidget {
  final DocumentSnapshot goal;

  TaskListPage({required this.goal});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Function to delete a task
  Future<void> _deleteTask(
      BuildContext context, DocumentReference taskRef) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
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
      await taskRef.delete();
    }
  }

  // Function to edit a task (copied from task.dart)
  Future<void> _editTask(
      DocumentReference taskRef, Map<String, dynamic> currentTaskData) async {
    // Create controllers and variables with current task values
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
        initialTime: _selectedTime ?? TimeOfDay.now(),
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
                    // Task Name Input
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Time Selection
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

                    // Display the selected time if "Specific time" is chosen
                    if (_selectedOption == 'Specific time' &&
                        _selectedTime != null)
                      Text('Selected Time: ${_selectedTime!.format(context)}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => _deleteTask(context, taskRef),
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Update the task data in Firestore
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

  // Function to add a task to the current goal
  Future<void> _addTask(BuildContext context) async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(
          goalStartDate: widget.goal['startDate'].toDate(),
          goalEndDate: widget.goal['endDate'].toDate(),
        ),
      ),
    );

    if (newTask != null) {
      await widget.goal.reference.collection('tasks').add(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.goal['title']}'),
        backgroundColor: const Color(0xFFEBEAE3),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _addTask(context),
                child: const Text('Add New Task'),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.goal.reference.collection('tasks').snapshots(),
              builder: (context, taskSnapshot) {
                if (!taskSnapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final tasks = taskSnapshot.data!.docs;
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks added yet.'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    String taskStartDate = _formatDate(task['startDate']);
                    String taskEndDate = _formatDate(task['endDate']);
                    return ListTile(
                      title: Text(task['task']),
                      subtitle: Text(
                        'Repeat every: ${task['repeatInterval']} days\nDate: $taskStartDate to $taskEndDate',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editTask(task.reference,
                                  task.data() as Map<String, dynamic>);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
