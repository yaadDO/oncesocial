import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../app.dart';

class FirebaseApi {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Make background handler static and add pragma
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    _handleNotification(message);
  }

  static Future<void> initNotifications() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined permission');
    }

    // Register background handler with static reference
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await updateFCMToken(newToken);
    });

    // Get token and save to Firestore
    final token = await _firebaseMessaging.getToken();
    await updateFCMToken(token);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'fcmToken': token});
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initializationSettings);

    // Handle messages
    FirebaseMessaging.onMessage.listen(_showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotification);
  }

  static void _showNotification(RemoteMessage message) {
    print('Received message: ${message.messageId}');
    print('Notification data: ${message.data}');

    final notification = message.notification;
    if (notification == null) {
      print('Notification is null');
      return;
    }

    _notificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'messages_channel',
          'Messages Notifications',
          importance: Importance.high,
          priority: Priority.high,
          colorized: true,
          color: Colors.blue,
        ),
      ),
    );
  }

  static void _handleNotification(RemoteMessage message) {
    final senderId = message.data['senderId'];
    if (senderId != null) {
      navigatorKey.currentState?.pushNamed(
        '/ChatPage',
        arguments: senderId,
      );
    }
  }

  static Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleNotification(initialMessage);
    }

    // Also handle any interaction when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotification);
  }

  // In FirebaseApi class
  static Future<void> updateFCMToken([String? token]) async {
    if (token == null) {
      print('FCM token is null');
      return;
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'fcmToken': token});
    }
  }
}