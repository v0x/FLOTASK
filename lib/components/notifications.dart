import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/*Notification Type Selected: Local
 *Why?: It can run in background even if the app itself is closed
 *      It relies on the Android OS, so locally dependent, can still run even if servers are down
*/

//have a reminder for a time the user has set for a particular task and only give the notification if the task is incomplete. 
//if the setreminder time is passed, the day is nearly over, AND the user has not completed a task yet, another reminder will be pushed
class Task {
  final int id;
  final String taskName;
  final bool daily;
  bool completed;
  final int setReminderHour;
  final int setReminderMinute;

  Task({
    required this.id,
    required this.taskName,
    required this.daily,
    this.completed = false,
    required this.setReminderHour,
    required this.setReminderMinute,
  });
}

List<Task> tasks = [
  Task(id: 0, taskName: "Task 1", daily: true, completed: true, setReminderHour: 21, setReminderMinute: 0),
  Task(id: 1, taskName: "Task 2", daily: false, completed: false,setReminderHour: 16, setReminderMinute: 55),
  Task(id: 2, taskName: "Task 3", daily: false, completed: true, setReminderHour: 16, setReminderMinute: 54),
  Task(id: 3, taskName: "Task 4", daily: true, completed: false, setReminderHour: 16, setReminderMinute: 56),
];

class Notifications{
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/*
  void requestPerms(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestPermission();
  }
  */ 
  Future<void> initState() async{
    WidgetsFlutterBinding.ensureInitialized();
    //Timezone Related
    tz.initializeTimeZones();
    //Grabbing timezone info from the device
    String deviceTZ = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTZ));
    //Notifications Related
    //ic_launcher is used by android to display app icon in notifications
    const AndroidInitializationSettings androidInitializationSettings 
      = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings 
      = InitializationSettings(android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    //requestPerms(flutterLocalNotificationsPlugin);
    scheduleNotifsForTasks(tasks, flutterLocalNotificationsPlugin);
  }

  tz.TZDateTime _nextInstanceOfTime(int hourSpecified, int minuteSpecified) {
    final tz.TZDateTime currentTime = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      currentTime.year,
      currentTime.month,
      currentTime.day,
      hourSpecified,
      minuteSpecified
    );

    //Pretty much once the scheduled time for the current day has passed, we schedule for the next day.
    if(scheduledTime.isBefore(currentTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  //iterating through all the tasks to setup notifications for them
  void scheduleNotifsForTasks(List<Task> tasks, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    for (var task in tasks) {
      setupNotif(task, flutterLocalNotificationsPlugin);
    }
  }

  Future<void> setupNotif(Task task, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(task.setReminderHour, task.setReminderMinute);
    tz.TZDateTime lastMinute = _nextInstanceOfTime(23, 0);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id, //Notif ID: Using enum index for the notification ID.
      task.taskName, //Title
      "You haven't watered your plants today! Let's help them grow!", //Notifcation Description
      scheduledDate, //Date
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id', //ChannelID
          'Tasks', //Channel
          channelDescription: 'Channel for task notifications', //Channel Description
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: task.daily ? DateTimeComponents.time : null, 
      //If the daily value is true, repeat notification everday, if not, don't.
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id+1000, //Notif ID: Using enum index for the notification ID.
      task.taskName, //Title
      "Time's almost up for today! Let's water the plants before time runs out!", //Notifcation Description
      lastMinute, //Date
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id', //ChannelID
          'Tasks', //Channel
          channelDescription: 'Channel for task notifications', //Channel Description
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: task.daily ? DateTimeComponents.time : null, 
      //If the daily value is true, repeat notification everday, if not, don't.
    );
  }

}