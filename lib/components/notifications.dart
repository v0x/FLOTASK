import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

enum DummyTasks {
    sampleTask1('Task 1', true, 1),
    sampleTask2('Task 2', false, 5),
    sampleTask3('Task 3', false, 7),
    sampleTask4('Task 4', true, 10),
    sampleTask5('Task 5', false, 8);

    const DummyTasks(this.taskName, this.completed, this.reminderTime);
    final String taskName;
    final bool completed;
    final int reminderTime;
}

class Notifications{
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initState() async{
    //ic_launcher is used by android to display app icon in notifications
    const AndroidInitializationSettings androidInitializationSettings 
      = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings 
      = InitializationSettings(android: androidInitializationSettings);
  }

  //need to create an await function that waits for init to finish

  @override
     Widget build(BuildContext context) {
      return Card();
     }
}