import 'package:flotask/components/pomodoroTimer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/task_model.dart';
import '../components/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/goal_service.dart';
import '../models/goal_model.dart';
import 'package:intl/intl.dart';

final GoalService goalService = GoalService();
final TaskService taskService = TaskService();
List<Task> tasks = [];
int currlen = 0;
bool isLoading = true;

Color getColor(String colorString) {
  try {
    String hex = colorString.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex"; // Add alpha if missing
    }
    return Color(int.parse(hex, radix: 16));
  } catch (e) {
    return Colors.white; // Default color on error
  }
}

int timeDealer(int timeUnit) {
  try {
    return timeUnit; //Default to 25
  } catch (e) {
    return 5; 
  }
}

  class PomodoroPage extends StatefulWidget {
    const PomodoroPage({
      super.key,
    });
    @override
    State<PomodoroPage> createState() => _PomodoroState();
  }

  class _PomodoroState extends State<PomodoroPage> {
    final User? currentUser = FirebaseAuth.instance.currentUser;
  late final String userId;
  late final CollectionReference goalsCollection;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      userId = currentUser!.uid;
      goalsCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('goals');
    }
    tasks = [];
    _fetchGoalsAndTasks();
  }

    final TextEditingController taskController = TextEditingController();
    Task? selectedTask;
    
    Future<void> _fetchGoalsAndTasks() async {
      try {
        QuerySnapshot goalSnapshot = await goalsCollection.get();
        List<Goal> fetchedGoals = goalSnapshot.docs.map((doc) => Goal.fromDocument(doc)).toList();
        //tasks.add(Task(id: "9999", taskName: "Select Task", repeatInterval: 9999, startDate: DateTime.now(), endDate: DateTime.now(), workTime: 0, breakTime: 0, taskColor: "#FFFFFF", status: "status", totalRecurrences: 999, totalCompletedRecurrences: 999));
        for (var goal in fetchedGoals) {
          QuerySnapshot taskSnapshot = await goalsCollection.doc(goal.id).collection('tasks').get();
          List<Task> fetchedTasks = taskSnapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
          for (var task in fetchedTasks) {
            tasks.add(task);
          }
        }
      } catch (e) {
        print('Error fetching tasks: $e');
      }
      finally {
        setState(() {
          isLoading = false;
        });
    }
    }

    Future<void> _somethingChanged() async {
    //Listen to all 'tasks' under the current user's 'goals'
      FirebaseFirestore.instance
          .collectionGroup('tasks')
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          DocumentReference goalRef = change.doc.reference.parent.parent!;
          if (goalRef.parent.parent!.id == userId) { // Ensure it belongs to current user
            Task task = Task.fromDocument(change.doc);
            
            if (change.type == DocumentChangeType.added) {
              setState(() {
                tasks.add(task);
              });
            } else if (change.type == DocumentChangeType.removed) {
              setState(() {
                tasks.removeWhere((t) => t.id == task.id);
              });
            } else if (change.type == DocumentChangeType.modified) {
              setState(() {
                int index = tasks.indexWhere((t) => t.id == task.id);
                if (index != -1) {
                  tasks[index] = task;
                }
              });
            }
          }
        }
      });
    }
    

    @override
    Widget build(BuildContext context) {
      return Card(
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLoading
                ? CircularProgressIndicator()
                :
                DropdownButton<Task>(
                  value: selectedTask,
                  hint: Text('Select Task'),
                  items: tasks.map((Task task) {
                    return DropdownMenuItem<Task>(
                      value: task,
                      child: Text(task.taskName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                    );
                  }).toList(),
                  onChanged: (Task? newValue) {
                    setState(() {
                      selectedTask = newValue;
                    });
                  },
                ),
              ),
              Column(
                children: <Widget>[
                  selectedTask != null
                  ? Column(
                    children: <Widget>[
                      SizedBox(height: 10,),
                      Container(
                        width: 320,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                        ),
                        child: 
                        Center(child: 
                          Text("Current Task", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              ),)),
                        ),
                      Container(
                        padding: EdgeInsets.all(3),
                        width: 320,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                        child: Row(
                          children: [
                            
                            //the mini box that contains the priority number + time info
                            Container(
                              padding: EdgeInsets.all(4),
                              height: 60,
                              decoration: BoxDecoration(
                              color: selectedTask!.taskColor.toColor()?.withOpacity(0.2),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 10,),
                                  Text(
                                    selectedTask!.workTime.toString()+" min.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: 
                              Container(
                                padding: EdgeInsets.all(4),
                                height: 60,
                                decoration: BoxDecoration(
                                color: selectedTask!.taskColor.toColor()?.withOpacity(0.3),
                                ),
                                child: 
                                Center(
                                  child: 
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        selectedTask!.taskName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],),
                      ),
                      SizedBox(height: 16,),
                     PomodoroTimer(
                      workTime: timeDealer(selectedTask!.workTime), 
                      breakTime: timeDealer(selectedTask!.breakTime),
                      taskColor: getColor(selectedTask!.taskColor),)
                    ]
                  )
                  :
                  Text(
                    'No Task Currently Selected',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
                ),
              ]
          ),
        ),
      )
      );
    }
  }
