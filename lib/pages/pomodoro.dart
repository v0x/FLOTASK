import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

  enum TaskLabel {
    d('Select Task', Colors.white),
    sampleTask1('Task 1', Colors.blue),
    sampleTask2('Task 2', Colors.pink),
    sampleTask3('Task 3', Colors.green),
    sampleTask4('Task 4', Colors.orange),
    sampleTask5('Task 5', Colors.purple);

    const TaskLabel(this.taskName, this.taskColor);
    final String taskName;
    final Color taskColor;
  }

  class PomodoroPage extends StatefulWidget {
    
    const PomodoroPage({
      super.key,
    });
    
    State<PomodoroPage> createState() => _PomodoroState();

  }

  class _PomodoroState extends State<PomodoroPage> {
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownMenu<TaskLabel>(
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
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
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
              Container(
              child: Center(
                child: selectedTask != null
                ? Text(
                  selectedTask!.taskName,
                  style: TextStyle(
                    color: selectedTask!.taskColor,
                    fontSize: 18,
                  ),
                )
                :
                Text(
                  'No Task Currently Selected',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              ),
            ]
          ),
        ),
      );
    }
  }
