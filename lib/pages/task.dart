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

  // Function to update task status in Firestore
  Future<void> _updateTaskStatus(
      DocumentReference taskRef, bool isCompleted) async {
    await taskRef.update({'status': isCompleted ? 'completed' : 'todo'});
  }

  // Function to build the list of tasks based on the status
  Widget _buildTaskList(String status) {
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
                          Text('Repeat Interval: ${task['repeatInterval']}'),
                    );
                  }).toList(),
                );
              },
            ),
          );
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
            "Tasks", //page title
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
