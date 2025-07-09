import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iOSImplementation != null) {
      await iOSImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> scheduleWeeklyAttendanceReminders() async {
    await cancelAllNotifications();

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'attendance_reminder_channel',
      'Attendance Reminders',
      channelDescription: 'Weekly reminders to mark attendance',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    for (int weekday = 1; weekday <= 5; weekday++) {
      try {
        final scheduledDate = _nextInstanceOfSixPM(weekday);
        final dayName = [
          '',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday'
        ][weekday];

        await flutterLocalNotificationsPlugin.zonedSchedule(
          weekday,
          'TimeWise Reminder',
          'Don\'t forget to mark your attendance for today!',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        debugPrint(
            '✅ Scheduled notification for $dayName (ID: $weekday) at $scheduledDate');
      } catch (e) {
        debugPrint('❌ Error scheduling notification for weekday $weekday: $e');
      }
    }
    await Future.delayed(const Duration(milliseconds: 100));
    await checkPendingNotifications();
  }

  tz.TZDateTime _nextInstanceOfSixPM(int targetWeekday) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18,
      0,
      0,
    );
    int daysToAdd = (targetWeekday - now.weekday) % 7;
    if (daysToAdd == 0 && now.hour >= 18) {
      daysToAdd = 7;
    }
    scheduledDate = scheduledDate.add(Duration(days: daysToAdd));

    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      99,
      'Test Notification',
      'If you see this, notifications are working!',
      notificationDetails,
    );
  }

  Future<void> checkPendingNotifications() async {
    final List<PendingNotificationRequest> pendingRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if (pendingRequests.isEmpty) {
      debugPrint('No pending notifications found.');
      debugPrint('--- DEBUGGING SCHEDULED DATES ---');
      for (int i = 1; i <= 5; i++) {
        final scheduledDate = _nextInstanceOfSixPM(i);
        final dayName =
            ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'][i];
        debugPrint('$dayName (weekday $i): $scheduledDate');
      }
      debugPrint('Current time: ${tz.TZDateTime.now(tz.local)}');
      debugPrint('-----------------------------');
    } else {
      debugPrint('--- PENDING NOTIFICATIONS ---');
      for (var request in pendingRequests) {
        debugPrint(
            'ID: ${request.id} | Title: ${request.title} | Body: ${request.body}');
      }
      debugPrint('-----------------------------');
    }
  }

  Future<void> testImmediateNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final testTime = now.add(const Duration(seconds: 10));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      'Test Notification',
      'This should appear in 10 seconds',
      testTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('Scheduled test notification for: $testTime');
  }
}
