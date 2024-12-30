import 'dart:io';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

// class NotificationService {
//   // Singleton pattern implementation
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   //     FlutterLocalNotificationsPlugin();

//   bool _initialized = false;

//   // Channel configurations
//   static const String channelId = 'event_reminders';
//   static const String channelName = 'Event Reminders';
//   static const String channelDescription = 'Notifications for calendar events';

//   Future<void> initialize() async {
//     if (_initialized) return;

//     try {
//       // Request permissions
//       await requestNotificationPermission();

//       // Initialize timezone data
//       tz.initializeTimeZones();
//       final location = tz.local;
//       print(location);
//       // tz.setLocalLocation(tz.getLocation(location));

//       // Platform-specific initialization settings
//       // const androidSettings =
//       //     AndroidInitializationSettings('@mipmap/ic_launcher');
//       // const darwinSettings = DarwinInitializationSettings(
//       //   requestSoundPermission: true,
//       //   requestBadgePermission: true,
//       //   requestAlertPermission: true,
//       // );

//       // const initSettings = InitializationSettings(
//       //   android: androidSettings,
//       //   // iOS: darwinSettings,
//       // );

//       // Initialize plugin
//       // await flutterLocalNotificationsPlugin.initialize(
//       //   initSettings,
//       //   onDidReceiveNotificationResponse: _onNotificationTapped,
//       // );

//       // Create notification channel for Android
//       await _createNotificationChannel();

//       _initialized = true;
//       print('Notification service initialized successfully');
//     } catch (e) {
//       print('Error initializing notification service: $e');
//       rethrow;
//     }
//   }

//   // void _onNotificationTapped(NotificationResponse details) {
//   //   print('Notification tapped - Payload: ${details.payload}');
//   //   // Add your notification tap handling logic here
//   // }

//   Future<void> requestNotificationPermission() async {
//     if (Platform.isAndroid) {
//       // final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//       //     flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//       //         AndroidFlutterLocalNotificationsPlugin>();

//       // await androidImplementation?.requestExactAlarmsPermission();
//       // await androidImplementation?.requestNotificationsPermission();

//       final status = await Permission.notification.request();
//       print('Android notification permission status: ${status.isGranted}');
//     }
//     // else if (Platform.isIOS) {
//     //   // final bool? result = await flutterLocalNotificationsPlugin
//     //   //     .resolvePlatformSpecificImplementation<
//     //   //         IOSFlutterLocalNotificationsPlugin>()
//     //   //     ?.requestPermissions(
//     //   //       alert: true,
//     //   //       badge: true,
//     //   //       sound: true,
//     //   //     );
//     //   // print('iOS notification permission status: $result');
//     // }
//   }

//   Future<void> _createNotificationChannel() async {
//     // const AndroidNotificationChannelGroup channel =
//     //     AndroidNotificationChannelGroup(channelId, channelName,
//     //         description: channelDescription);

//     // await flutterLocalNotificationsPlugin
//     //     .resolvePlatformSpecificImplementation<
//     //         AndroidFlutterLocalNotificationsPlugin>()
//     //     ?.createNotificationChannelGroup(channel);
//   }

//   Future<void> scheduleEventNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime eventTime,
//     Duration reminderBefore = const Duration(minutes: 15),
//   }) async {
//     if (!_initialized) {
//       print('Notification service not initialized');
//       return;
//     }

//     {
//       final scheduledDate = tz.TZDateTime.from(
//         eventTime.subtract(reminderBefore),
//         tz.local,
//       );

//       if (scheduledDate.isBefore(DateTime.now())) {
//         print('Cannot schedule notification for past time');
//         return;
//       }

//       //     const notificationDetails = NotificationDetails(
//       //       android: AndroidNotificationDetails(
//       //         channelId,
//       //         channelName,
//       //         channelDescription: channelDescription,
//       //         importance: Importance.max,
//       //         priority: Priority.high,
//       //         showWhen: true,
//       //       ),
//       //       // iOS: DarwinNotificationDetails(
//       //       //   presentAlert: true,
//       //       //   presentBadge: true,
//       //       //   presentSound: true,
//       //       // ),
//       //     );

//       //     await flutterLocalNotificationsPlugin.zonedSchedule(
//       //       id,
//       //       title,
//       //       body,
//       //       scheduledDate,
//       //       notificationDetails,
//       //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       //       uiLocalNotificationDateInterpretation:
//       //           UILocalNotificationDateInterpretation.absoluteTime,
//       //     );

//       //     print('Notification scheduled for $scheduledDate');
//       //   } catch (e) {
//       //     print('Error scheduling notification: $e');
//       //     rethrow;
//       //   }
//       // }

//       // Future<void> cancelNotification(int id) async {
//       //   try {
//       //     await flutterLocalNotificationsPlugin.cancel(id);
//       //     print('Notification cancelled - ID: $id');
//       //   } catch (e) {
//       //     print('Error cancelling notification: $e');
//       //     rethrow;
//       //   }
//       // }

//       // Future<void> cancelAllNotifications() async {
//       //   try {
//       //     await flutterLocalNotificationsPlugin.cancelAll();
//       //     print('All notifications cancelled');
//       //   } catch (e) {
//       //     print('Error cancelling all notifications: $e');
//       //     rethrow;
//       //   }
//       // }
//     }
//   }
// }
