import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_goal.dart';

//stateful widget for the Taskpage
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  _TaskPageState createState() => _TaskPageState();
}

//state class for TaskPage
class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //initialze the tab controller with 2 tabs
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  //dispose the tab controller when not needed
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // (wr2)Function to update task status in Firestore
  Future<void> _updateTaskStatus(
      DocumentReference taskRef, bool isCompleted) async {
    await taskRef.update({'status': isCompleted ? 'completed' : 'todo'}); //wr2
  }

  //work review2
  // Function to edit a task
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
                                _selectTime(context,
                                    setState); // Open time picker if "Specific time" is selected
                              } else {
                                _selectedTime = null; // Reset the selected time
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
                    // Update the task data in Firestore
                    await taskRef.update({
                      'task': _taskController.text,
                      //'repeatInterval': _repeatIntervalNotifier.value,
                      'selectedTime': _selectedTime != null
                          ? '${_selectedTime!.hour}:${_selectedTime!.minute}'
                          : null, // Save selected time if any, otherwise set null
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

  // Function to delete a task (wr2)
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
  //WR2

  // Function to build the list of tasks based on the status
  Widget _buildTaskList(String status) {
    final currentDate = DateTime.now(); //get the current date

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('goals')
          .snapshots(), // Listen for changes in the goals collection
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final goals = snapshot.data!.docs;
        List<Widget> taskWidgets = [];

        for (var goal in goals) {
          // Get tasks under each goal
          taskWidgets.add(
            StreamBuilder<QuerySnapshot>(
              stream: goal.reference
                  .collection('tasks')
                  .where('status', isEqualTo: status)
                  .snapshots(),
              builder: (context, taskSnapshot) {
                if (!taskSnapshot.hasData) {
                  return const SizedBox.shrink(); // Show nothing if no data
                }

                final tasks = taskSnapshot.data!.docs;
                if (tasks.isEmpty) {
                  return const SizedBox
                      .shrink(); // If no tasks match, show nothing
                }

                return Column(
                  children: tasks.map((task) {
                    final taskRef = task.reference;
                    bool isCompleted = task['status'] == 'completed';

                    // Include the goal name in the task display
                    String goalName = goal['title']; // Goal title

                    DateTime? startDate = (task['startDate'] != null)
                        ? (task['startDate'] as Timestamp).toDate()
                        : null;
                    DateTime? endDate = (task['endDate'] != null)
                        ? (task['endDate'] as Timestamp).toDate()
                        : null;
                    int repeatInterval = task['repeatInterval'];
                    String? selectedTime = task['selectedTime'];

                    // Filter tasks based on the current date and recurring dates
                    if (startDate != null && endDate != null) {
                      List<DateTime> recurringDates = [];

                      // (WR3)Generate recurring dates between start and end date based on the repeat interval
                      for (DateTime date = startDate;
                          date.isBefore(endDate) ||
                              date.isAtSameMomentAs(endDate);
                          date = date.add(Duration(days: repeatInterval))) {
                        recurringDates.add(date);
                      }

                      // Check if the current date matches any of the recurring dates
                      bool isTaskForToday = recurringDates.any((date) =>
                          date.year == currentDate.year &&
                          date.month == currentDate.month &&
                          date.day == currentDate.day);

                      // If the task is not scheduled for today, skip it (WR3)
                      if (!isTaskForToday) {
                        return const SizedBox.shrink();
                      }
                    }

                    return ListTile(
                      leading: Checkbox(
                        value: isCompleted,
                        //value: status == 'completed',
                        onChanged: (bool? value) {
                          if (value != null) {
                            _updateTaskStatus(taskRef, value);
                          }
                        },
                      ),
                      title: Text(task['task']),
                      subtitle:
                          //Text('Repeat Interval: ${task['repeatInterval']}'),
                          Text(
                              'Goal: $goalName\nTime: ${task['selectedTime'] ?? 'Any time'}'), // Goal name and repeat interval
                      trailing: Row(
                        //update UI for edit and delete (WR3)
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editTask(
                                  taskRef, task.data() as Map<String, dynamic>);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          );
        }
        // If no tasks for today, show a simple message
        if (taskWidgets.isEmpty) {
          return Center(child: const Text('No tasks for today.'));
        }

        return ListView(children: taskWidgets);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar with title and tabs
      appBar: AppBar(
        title: Center(
          child: Text(
            "Daily tasks", //page title
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
          ],
        ),
      ),
      //content of each tab
      body: TabBarView(
        controller: _tabController, //controller for tabs
        children: [
          _buildTaskList('todo'), // Fetch and display "To-do" tasks
          _buildTaskList('completed'), // Fetch and display "Completed" tasks
        ],
      ),
      //floating action button to ass a new goal
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton(
          onPressed: () {
            //navigate to add goal page when clicking on the button
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddGoalPage()),
            );
          },
          backgroundColor: Colors.black,
          shape: const CircleBorder(), //circle button shape
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
