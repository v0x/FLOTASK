import 'package:flotask/components/pomodoroTimer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//dummy tasks for navbar
  enum TaskLabel {
    d('Select Task', Colors.white, 10, 5, 0),
    sampleTask1('Task 1', Colors.blue, 1, 1, 1),
    sampleTask2('Task 2', Colors.pink, 30, 5, 2),
    sampleTask3('Task 3', Colors.green, 40, 7, 3),
    sampleTask4('Task 4', Colors.orange, 60, 10, 4),
    sampleTask5('Task 5', Colors.purple, 15, 2, 5);

    const TaskLabel(this.taskName, this.taskColor, this.workTime, this.breakTime, this.priority);
    final String taskName;
    final Color taskColor;
    final int workTime;
    final int breakTime;
    final int priority;
  }

  //this page will have multiple states
  class PomodoroPage extends StatefulWidget {
    const PomodoroPage({
      super.key,
    });
    
    State<PomodoroPage> createState() => _PomodoroState();
  }

  class _PomodoroState extends State<PomodoroPage> {
    //variables for navbar selection
    final TextEditingController taskController = TextEditingController();
    TaskLabel? selectedTask;
    
    @override
    Widget build(BuildContext context) {
      return Card(
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Column(
            children: <Widget>[
              //navbar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: 
                DropdownMenu<TaskLabel>(
                  initialSelection: TaskLabel.d,
                  controller: taskController,
                  requestFocusOnTap: false,
                  onSelected: (TaskLabel? task) {
                    setState(() {
                      selectedTask = task;
                    });
                  },
                  dropdownMenuEntries: TaskLabel.values
                  .map<DropdownMenuEntry<TaskLabel>>(
                  //list of tasks in the navbar
                  (TaskLabel task) {
                    return DropdownMenuEntry<TaskLabel>(
                      value: task,
                      label: task.taskName,
                      enabled: task.taskName != 'Select Task',
                    );
                    }).toList(),
                    menuStyle: MenuStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  inputDecorationTheme: 
                  InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    
                  ),
                  
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
                              color: selectedTask!.taskColor.withOpacity(0.2),
                              ),
                              child: Row(
                                children: [
                                  //circle containing priority number
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: selectedTask!.taskColor.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        selectedTask!.priority.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

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
                                color: selectedTask!.taskColor.withOpacity(0.3),
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
                     //passing parameters of selectedTask into PomodoroTimer component
                     PomodoroTimer(
                      workTime: selectedTask!.workTime, 
                      breakTime: selectedTask!.breakTime,
                      taskColor: selectedTask!.taskColor,)
                    ]
                  )
                  :
                  //default
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
      );
    }
  }
