// In lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
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
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await requestPermissions();
  }

  /// CORRECTED: Now requests the exact alarm permission in addition to standard notifications.
  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Request standard notification permission
      await androidImplementation.requestNotificationsPermission();
      // Request permission to schedule exact alarms
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

    // Schedule for Monday (1) through Friday (5)
    for (int weekday = 1; weekday <= 5; weekday++) {
      try {
        final scheduledDate = _nextInstanceOfSixPM(weekday);
        final dayName = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'][weekday];
        
        await flutterLocalNotificationsPlugin.zonedSchedule(
          weekday, // Use weekday as ID (1-5)
          'TimeWise Reminder',
          'Don\'t forget to mark your attendance for today!',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        
        debugPrint('✅ Scheduled notification for $dayName (ID: $weekday) at $scheduledDate');
      } catch (e) {
        debugPrint('❌ Error scheduling notification for weekday $weekday: $e');
      }
    }
    
    // Check what was actually scheduled
    await Future.delayed(const Duration(milliseconds: 100));
    await checkPendingNotifications();
  }

  tz.TZDateTime _nextInstanceOfSixPM(int targetWeekday) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // Create a datetime for 6 PM today
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18, // 6 PM
      0,  // 0 minutes
      0,  // 0 seconds
    );
    
    // Calculate days to add to reach the target weekday
    int daysToAdd = (targetWeekday - now.weekday) % 7;
    
    // If it's the target day but past 6 PM, schedule for next week
    if (daysToAdd == 0 && now.hour >= 18) {
      daysToAdd = 7;
    }
    
    // Add the calculated days
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
      
      // Additional debugging - check what dates we're trying to schedule
      debugPrint('--- DEBUGGING SCHEDULED DATES ---');
      for (int i = 1; i <= 5; i++) {
        final scheduledDate = _nextInstanceOfSixPM(i);
        final dayName = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'][i];
        debugPrint('$dayName (weekday $i): $scheduledDate');
      }
      debugPrint('Current time: ${tz.TZDateTime.now(tz.local)}');
      debugPrint('-----------------------------');
    } else {
      debugPrint('--- PENDING NOTIFICATIONS ---');
      for (var request in pendingRequests) {
        debugPrint('ID: ${request.id} | Title: ${request.title} | Body: ${request.body}');
      }
      debugPrint('-----------------------------');
    }
  }

  // Test with immediate notifications
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
