// ignore_for_file: avoid_print

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  // Factory constructor to return the single instance
  factory NotificationService() => _instance;

  // Private constructor
  NotificationService._internal();

  // Flutter Local Notifications plugin instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  }

  Future<void> init() async {
    try {
      // Initialize time zones
      tz.initializeTimeZones();

      // Android-specific initialization settings
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS-specific initialization settings
      const DarwinInitializationSettings iosInitSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        // Optional: handle received notifications on iOS
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      // Initialize the notification plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        // Optional: handle notification tap
        onDidReceiveNotificationResponse: _onSelectNotification,
      );

      // Configure Android notification channel (important for Android 8.0+)
      await _configureAndroidNotificationChannel();

      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  // Configure Android notification channel
  Future<void> _configureAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'event_reminders', // id
      'Event Reminders', // name
      description: 'Notifications for upcoming events',
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  void _onSelectNotification(NotificationResponse details) {
    print('Notification tapped - Payload: ${details.payload}');
  }

  // Schedule a notification for an event
  Future<void> scheduleEventNotification({
    required int id,
    required String title,
    required String body,
    required DateTime eventTime,
    Duration reminderBefore = const Duration(minutes: 15),
  }) async {
    try {
      // Calculate notification time (before the event)
      final notificationTime = eventTime.subtract(reminderBefore);

      // Android-specific notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'event_reminders',
        'Event Reminders',
        importance: Importance.high,
        priority: Priority.high,
        // Additional customization options can be added here
      );

      // iOS-specific notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined platform-specific details
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(notificationTime, tz.local),
        platformDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: title,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('Notification scheduled - ID: $id, Time: $notificationTime');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      print('Notification cancelled - ID: $id');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
}
