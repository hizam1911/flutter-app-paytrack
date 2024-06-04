import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:quiver/time.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> requestNotificationPermission() async {

  }

  Future<void> initNotification() async {
    // For asking permission
    // final AndroidFlutterLocalNotificationsPlugin? androidImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    // final bool? grantedNotificationPermission = await androidImplementation?.requestExactAlarmsPermission() ?? false;

    // For status
    // final bool isGranted = await notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.canScheduleExactNotifications() ?? false;
    // if (isGranted == true) {
    //   // Permission granted
    //   print('Alarm permission granted');
    // } else if (isGranted == false) {
    //   // Permission denied
    //   print('Alarm permission denied');
    // } else {
    //   // Permission request cancelled or other status
    //   print('Alarm permission request cancelled.');
    // }

    // Permission Handler Notification
    final PermissionStatus notificationStatus = await Permission.notification.request();
    if (notificationStatus.isGranted) {
      // Permission granted
      print('Notification permission granted');
    } else if (notificationStatus.isDenied) {
      // Permission denied
      print('Notification permission denied');
    } else if (notificationStatus.isPermanentlyDenied) {
      // Permission permanently denied (user opted out)
      print('Notification permission permanently denied');
      await openAppSettings(); // Open app settings where user can enable permission
    } else {
      // Permission request cancelled or other status
      print('Notification permission request cancelled.');
    }

    // Permission Handler Alarm
    final PermissionStatus alarmStatus = await Permission.scheduleExactAlarm.request();
    if (alarmStatus.isGranted) {
      // Permission granted
      print('Alarm permission granted');
    } else if (alarmStatus.isDenied) {
      // Permission denied
      print('Alarm permission denied');
    } else if (alarmStatus.isPermanentlyDenied) {
      // Permission permanently denied (user opted out)
      print('Alarm permission permanently denied');
      await openAppSettings(); // Open app settings where user can enable permission
    } else {
      // Permission request cancelled or other status
      print('Alarm permission request cancelled.');
    }

    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@drawable/notification_icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {}
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS
    );
    await notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max),
      iOS: DarwinNotificationDetails()
    );
  }

  notificationDetailsTriggerOnce() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max, onlyAlertOnce: true),
        iOS: DarwinNotificationDetails()
    );
  }

  Future showNotification({int id = 0, String? title, String? body, String? payload}) async {
    // initNotification();
    return notificationsPlugin.show(id, title, body, await notificationDetails());
  }

  tz.Location setLocal() {
    tz.Location localMalaysia = tz.getLocation('Asia/Singapore');
    return localMalaysia;
  }

  // only once notification
  Future<void> scheduleNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
    required DateTime scheduledNotificationDateTime,
  }) async {

    //debug
    print('DateTime Now: ' + DateTime.now().toString());
    print('TZDateTime Now: ' + tz.TZDateTime.now(setLocal()).toString());
    print('TZDateTime Scheduled: ' + scheduledNotificationDateTime.toString());

    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      nextInstanceOfTime(scheduledNotificationDateTime),
      // tz.TZDateTime.now(setLocal()).add(const Duration(seconds: 2)),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // tz.TZDateTime _nextInstanceOfTime(DateTime time) {
  //   final tz.TZDateTime now = tz.TZDateTime.now(setLocal());
  //   tz.TZDateTime scheduledDate = tz.TZDateTime(
  //       setLocal(), now.year, now.month, now.day, time.hour, time.minute);
  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 1));
  //   }
  //   return scheduledDate;
  // }

  //this is for weekly notification
  Future<void> scheduleNotifications({
    required String description,
    required String coralId,
  }) async {
    await notificationsPlugin.periodicallyShow(
      0,
      'repeating coral id: $coralId',
      'repeating description: $description',
      RepeatInterval.weekly,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   0,
    //   "Scheduled Title",
    //   description,
    //   tz.TZDateTime.now(setLocal()).add(
    //     const Duration(minutes: 1),
    //   ),
    //   NotificationDetails(android: _androidNotificationDetails),
    //   androidAllowWhileIdle: true,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    //   payload: coralId,
    //   matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    // );
  }
  //---------------------- LOL ---------------------------------------------

  // Future<void> _scheduleWeeklyNotification() async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'weekly channel id', 'weekly channel name',
  //       importance: Importance.max, priority: Priority.high);
  //   // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //   var platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics);
  //       // iOS: iOSPlatformChannelSpecifics);
  //
  //   // Specify the day and time to trigger the notification
  //   var time = TimeOfDay(hour: 10, minute: 0); // 10 AM
  //   var dayOfWeek = Day.monday; // Change the day as needed
  //
  //   // Schedule the notification
  //   await notificationsPlugin.zonedSchedule(
  //       0,
  //       'Weekly Notification',
  //       'This is a weekly notification',
  //       _nextInstanceOfDay(time, dayOfWeek),
  //       platformChannelSpecifics,
  //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //       uiLocalNotificationDateInterpretation:
  //       UILocalNotificationDateInterpretation.absoluteTime);
  // }
  //
  // tz.TZDateTime _nextInstanceOfDay(TimeOfDay time, Day dayOfWeek) {
  //   final now = tz.TZDateTime.now(setLocal());
  //   var scheduledDate = tz.TZDateTime(
  //       setLocal(), now.year, now.month, now.day, time.hour, time.minute, 0);
  //   if (scheduledDate.weekday == dayOfWeek.index + 1) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 7));
  //   } else {
  //     while (scheduledDate.weekday != dayOfWeek.index + 1) {
  //       scheduledDate = scheduledDate.add(const Duration(days: 1));
  //     }
  //   }
  //   return scheduledDate;
  // }
  //----------------------------------------------------------------------------------
  //once
  Future<void> scheduleOneTimeNotification(int notificationID, String title, String body, DateTime time) async {

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
        notificationID,
        title,
        body,
        nextInstanceOfTime(time),
        // tz.TZDateTime.now(setLocal()).add(const Duration(seconds: 3)),
        notificationDetailsTriggerOnce(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);

    //debug
    print('Type: Once');
    print('NotificationID: $notificationID');
    print('Title: $title');
    print('Body: $body');
    print('Time: $time');
  }

  tz.TZDateTime nextInstanceOfTime(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(setLocal());
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        setLocal(), now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  //weekly
  Future<void> scheduleWeeklyNotification(int notificationID, String title, String body, TimeOfDay time, Day dayOfWeek) async {

    //separate the date and time from scheduled date
    // Specify the day and time to trigger the notification
    // var time = TimeOfDay(hour: 10, minute: 0); // 10 AM
    // var dayOfWeek = Day.wednesday; // Wednesday

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
        notificationID,
        title,
        body,
        nextInstanceOfDay(time, dayOfWeek),
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);

    //debug
    print('Type: Weekly');
    print('NotificationID: $notificationID');
    print('Title: $title');
    print('Body: $body');
    print('Time: $time');
    print('Day: $dayOfWeek');
  }

  tz.TZDateTime nextInstanceOfDay(TimeOfDay time, Day day) {
    final now = tz.TZDateTime.now(setLocal());
    var scheduledDate = tz.TZDateTime(
        setLocal(), now.year, now.month, now.day, time.hour, time.minute, 0);
    while (scheduledDate.weekday != day.index) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    print('Weekly: $scheduledDate');
    return scheduledDate;
  }

  //separate the date and time from scheduled date
  //monthly
  Future<void> scheduleMonthlyNotification(int notificationID, String title, String body, TimeOfDay time, int dayOfMonth) async {

    // Specify the day and time to trigger the notification
    // var time = TimeOfDay(hour: 10, minute: 0); // 10 AM
    // var dayOfMonth = 8; // The day of the month to trigger the notification

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
        notificationID,
        title,
        body,
        nextInstanceOfMonth(time, dayOfMonth),
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);

    //debug
    print('Type: Monthly');
    print('NotificationID: $notificationID');
    print('Title: $title');
    print('Body: $body');
    print('Time: $time');
    print('Day: $dayOfMonth');
  }

  tz.TZDateTime nextInstanceOfMonth(TimeOfDay time, int dayOfMonth) {
    final now = tz.TZDateTime.now(setLocal());
    var scheduledDate = tz.TZDateTime(
        setLocal(), now.year, now.month, dayOfMonth, time.hour, time.minute, 0);
    if (scheduledDate.isBefore(now)) {
      if (daysInMonth(now.year, now.month) == 31) {
        scheduledDate = scheduledDate.add(const Duration(days: 31));
      } else if (daysInMonth(now.year, now.month) == 30) {
        scheduledDate = scheduledDate.add(const Duration(days: 30));
      } else if (daysInMonth(now.year, now.month) == 29) {
        scheduledDate = scheduledDate.add(const Duration(days: 29));
      } else if (daysInMonth(now.year, now.month) == 28) {
        scheduledDate = scheduledDate.add(const Duration(days: 28));
      }
    }
    print('Monthly: $scheduledDate');
    return scheduledDate;
  }

  Future<void> deleteNotification(int notificationID) async {
    print('notification ID: $notificationID');
    await notificationsPlugin.cancel(notificationID);
    print('notification ID: $notificationID');
    print('notification deleted successful');
  }

  Future<void> deleteNotificationSignOut() async {
    await notificationsPlugin.cancelAll();
    print('all notification deleted successful');
  }

  DateTime determineMaxDay(DateTime day) {

    if (daysInMonth(day.year, day.month) == 31) {
      day = DateTime.parse('2001-01-31 00:00:00');
    } else if (daysInMonth(day.year, day.month) == 30) {
      day = DateTime.parse('2001-01-30 00:00:00');
    } else if (daysInMonth(day.year, day.month) == 29) {
      day = DateTime.parse('2001-01-29 00:00:00');
    } else if (daysInMonth(day.year, day.month) == 28) {
      day = DateTime.parse('2001-01-28 00:00:00');
    }

    return day;
  }

  Future<bool> allPermissionAllowed() async {
    bool result = false;
    final PermissionStatus notificationStatus = await Permission.notification.request();
    final PermissionStatus alarmStatus = await Permission.scheduleExactAlarm.request();

    if (notificationStatus.isGranted && alarmStatus.isGranted) {
      result = true;
      print('Alarm and Notification permission granted');
    }

    return result;
  }


}