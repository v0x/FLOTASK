import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Task(id: 0, taskName: "Task 1", daily: true, completed: false, setReminderHour: 17, setReminderMinute: 30),
  Task(id: 1, taskName: "Task 2", daily: false, completed: false,setReminderHour: 17, setReminderMinute: 31),
  Task(id: 2, taskName: "Task 3", daily: false, completed: false, setReminderHour: 17, setReminderMinute: 32),
  Task(id: 3, taskName: "Task 4", daily: true, completed: false, setReminderHour: 17, setReminderMinute: 33),
];

class Notifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> requestPerms() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> initState() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Timezone setup
    tz.initializeTimeZones();
    String deviceTZ = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTZ));

    // Notifications initialization
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create the notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'task_channel_id',
            'Tasks',
            description: 'Channel for task notifications',
            importance: Importance.max,
          ),
        );
    print("Notification channel created.");

    await requestPerms();
    scheduleNotifsForTasks(tasks, flutterLocalNotificationsPlugin);

    // Test immediate and scheduled notifications
    //testImmediateNotification();
    testScheduledNotification();
  }

  tz.TZDateTime _nextInstanceOfTime(int hourSpecified, int minuteSpecified) {
    final tz.TZDateTime currentTime = tz.TZDateTime.now(tz.local);
    print("Current time: $currentTime");

    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      currentTime.year,
      currentTime.month,
      currentTime.day,
      hourSpecified,
      minuteSpecified,
    );

    if (scheduledTime.isBefore(currentTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    print("Scheduled time: $scheduledTime");
    return scheduledTime;
  }

  void scheduleNotifsForTasks(
      List<Task> tasks, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    for (var task in tasks) {
      if (!task.completed) {
        print("Scheduling notification for Task: ${task.taskName}");
        setupNotif(task, flutterLocalNotificationsPlugin);
      } else {
        print("Skipping completed Task: ${task.taskName}");
      }
    }
  }

  Future<void> setupNotif(
      Task task, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    tz.TZDateTime scheduledDate =
        _nextInstanceOfTime(task.setReminderHour, task.setReminderMinute);

    print("Scheduling '${task.taskName}' Notification for Time: $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id,
        task.taskName,
        "You haven't completed this task yet!",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel_id',
            'Tasks',
            channelDescription: 'Channel for task notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: task.daily ? DateTimeComponents.time : null,
      );
      print("Notification successfully scheduled for task: ${task.taskName}");
    } catch (e) {
      print("Error scheduling notification for task '${task.taskName}': $e");
    }
  }

  void testImmediateNotification() async {
    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        "Test Notification",
        "This is a test notification",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel_id',
            'Tasks',
            channelDescription: 'Channel for task notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      print("Test notification triggered.");
    } catch (e) {
      print("Error showing test notification: $e");
    }
  }

  void testScheduledNotification() async {
    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    print("Testing scheduled notification for $scheduledTime");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        999, // Unique ID for the test notification
        "Test Scheduled Notification",
        "This is a test for scheduled notifications",
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel_id',
            'Tasks',
            channelDescription: 'Channel for task notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("Scheduled notification successfully.");
    } catch (e) {
      print("Error scheduling test notification: $e");
    }
  }
}
