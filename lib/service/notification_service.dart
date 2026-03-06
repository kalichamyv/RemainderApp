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

    /// Notification channel
    const AndroidNotificationChannel channel =
    AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Reminder notifications',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Request Exact Alarm Permission (ANDROID 12+)
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  /// Request Notification Permission (Android 13+)
  static Future<void> requestPermission() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Notification Details
  static NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  /// ONE TIME
  static Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {

    if (dateTime.isBefore(DateTime.now())) {
      dateTime = DateTime.now().add(const Duration(seconds: 5));
    }

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

    print("Notification scheduled at: $scheduled");
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

  /// Cancel one
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
/// once user completed the task before time
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}