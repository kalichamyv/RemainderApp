import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// INIT
  static Future<void> init() async {

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings android =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: android);

    await _notifications.initialize(settings);

    const AndroidNotificationChannel channel =
    AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Reminder Notifications',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Permission
  static Future<void> requestPermission() async {

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  /// Notification Details
  static NotificationDetails _details() {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    return const NotificationDetails(android: androidDetails);
  }

  /// Calculate Reminder Time
  static DateTime getReminderTime(
      DateTime taskTime,
      String notificationOption,
      ) {

    switch (notificationOption) {

      case "15 mins before":
        return taskTime.subtract(const Duration(minutes: 15));

      case "30 mins before":
        return taskTime.subtract(const Duration(minutes: 30));

      case "45 mins before":
        return taskTime.subtract(const Duration(minutes: 45));

      case "1 hr before":
        return taskTime.subtract(const Duration(hours: 1));

      default:
        return taskTime;
    }
  }

  /// TODAY ONCE
  static Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {

    final tz.TZDateTime scheduled =
    tz.TZDateTime.from(dateTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// WEEKLY
  static Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {

    final tz.TZDateTime scheduled =
    tz.TZDateTime.from(dateTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// MONTHLY
  static Future<void> scheduleMonthly({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {

    final tz.TZDateTime scheduled =
    tz.TZDateTime.from(dateTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.dayOfMonthAndTime,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// CANCEL ONE
  static Future<void> cancel(int id) async {
    if (id <= 0) return;
    await _notifications.cancel(id);
  }

  /// CANCEL ALL
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}