import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceCloud {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("notification_icon");
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
      _viewMessage(remoteMessage);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage remoteMessage) async {},
    );
  }

  static Future<void> _viewMessage(RemoteMessage remoteMessage) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          "channel_id",
          "channel_name",
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: remoteMessage.notification?.title,
      body: remoteMessage.notification?.body,
      notificationDetails: notificationDetails,
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage,
  ) async {
    _viewMessage(remoteMessage);
  }
}
