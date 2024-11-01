import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/*
* DUMMY DATA
*/

final random = Random();

final List<Color> colors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
];

class Task {
  final String taskName;
  final Color taskColor;
  final int taskPriority;

  Task({required this.taskName, required this.taskColor, required this.taskPriority});
}

int numberOfTasks = 4;

List<Task> generateTasks(){
  final List<Task> tasks = [];
  for (int i=0; i<numberOfTasks; i++){
      tasks.add(Task(taskName: 'Task ${i}', taskColor: colors[random.nextInt(colors.length)], taskPriority: i,));
  }
  return tasks;
}

//UI

class Category extends StatefulWidget{
  @override
  _Category createState() => _Category();
}

class _Category extends State<Category> {

}

@override
Widget build(BuildContext context){
  return Scaffold();
}