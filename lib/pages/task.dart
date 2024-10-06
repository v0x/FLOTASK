import 'package:flutter/material.dart';
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
          // To-do section
          Container(
            color: const Color(0xFFEBEAE3),
            padding: const EdgeInsets.all(8.0),
            child: const Center(
              child: Text(
                'To-do Section',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Completed section
          Container(
            color: const Color(0xFFEBEAE3),
            padding: const EdgeInsets.all(8.0),
            child: const Center(
              child: Text(
                'Completed Section',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
