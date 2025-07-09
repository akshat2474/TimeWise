// In lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
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

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    
    // REMOVED: Timezone initialization is now handled in main.dart
    // tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    await requestPermissions();
  }

  // ... (The rest of the file remains the same)
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
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

    for (int i = 1; i <= 5; i++) { // 1=Monday, 5=Friday
      await flutterLocalNotificationsPlugin.zonedSchedule(
        i, // Unique ID for each day's notification
        'TimeWise Reminder',
        'Don\'t forget to mark your attendance for today!',
        _nextInstanceOfSixPM(i),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfSixPM(int day) {
    tz.TZDateTime scheduledDate = _nextInstanceOfDay(day);
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfDay(int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 18); // 6 PM
    
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
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
    } else {
      debugPrint('--- PENDING NOTIFICATIONS ---');
      for (var request in pendingRequests) {
        debugPrint(
            'ID: ${request.id} | Title: ${request.title} | Body: ${request.body}');
      }
      debugPrint('-----------------------------');
    }
  }
}
