import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // Note: Local notifications plugin removed temporarily to avoid Android build issues.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notification settings
  Future<void> initialize(BuildContext context) async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Local notifications initialization removed. Foreground notifications will be handled
    // via in-app SnackBars and by saving messages to Firestore.

    // Get FCM token
    String? token = await _messaging.getToken();
    await _saveFCMToken(token);

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) async {
      await _saveFCMToken(token);
    });

    // Handle incoming messages: save to Firestore and show a small in-app banner when foregrounded
    FirebaseMessaging.onMessage.listen((message) async {
      await _saveIncomingMessageToFirestore(message);
      if (message.notification != null && context.mounted) {
        final title = message.notification?.title ?? 'Notifikasi';
        final body = message.notification?.body ?? '';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$title\n$body')));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data['route'] as String?, context);
    });
  }

  // Save FCM token (token may be null)
  Future<void> _saveFCMToken(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', token);

      // Save token to user's document in Firestore if userId exists
      String? userId = prefs.getString('userId');
      if (userId != null && userId.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Save incoming FCM message into Firestore for history and UI consumption
  Future<void> _saveIncomingMessageToFirestore(RemoteMessage message) async {
    try {
      final payload = {
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': message.data,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      // If message has a target user id in data, save under that user; otherwise save globally
      final targetUserId = message.data['userId'] as String?;
      if (targetUserId != null && targetUserId.isNotEmpty) {
        await _firestore
            .collection('notifications')
            .add({...payload, 'userId': targetUserId});
      } else {
        await _firestore.collection('notifications').add(payload);
      }
    } catch (e) {
      print('Error saving incoming FCM message to Firestore: $e');
    }
  }

  // Handle notification tap
  void _handleNotificationTap(String? route, BuildContext context) {
    if (route != null && route.isNotEmpty) {
      Navigator.of(context).pushNamed(route);
    }
  }

  // Subscribe to topics
  Future<void> subscribeToTopics(List<String> topics) async {
    for (String topic in topics) {
      await _messaging.subscribeToTopic(topic);
    }
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (String topic in topics) {
      await _messaging.unsubscribeFromTopic(topic);
    }
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      String? fcmToken = userDoc.get('fcmToken') as String?;

      if (fcmToken == null) {
        throw Exception('User does not have an FCM token');
      }

      // Send notification through Firebase Cloud Functions
      await _firestore.collection('notifications').add({
        'token': fcmToken,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Send notification to a topic
  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'topic': topic,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification to topic: $e');
      rethrow;
    }
  }

  // Get notification history for user
  Stream<QuerySnapshot> getNotificationHistory(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }
}
