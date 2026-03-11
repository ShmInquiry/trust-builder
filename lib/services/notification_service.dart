import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_service_web.dart' as web_notif;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;
  bool _permissionGranted = false;

  static const _keyEnabled = 'notif_enabled';
  static const _keyHour = 'notif_hour';
  static const _keyMinute = 'notif_minute';
  static const _keyFairEnabled = 'notif_fair';
  static const _keyStalledEnabled = 'notif_stalled';
  static const _keyCriticalEnabled = 'notif_critical';

  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      try {
        final supported = web_notif.checkWebNotificationSupport();
        if (supported) {
          _permissionGranted = await web_notif.requestWebNotificationPermission();
        }
      } catch (_) {
        _permissionGranted = false;
      }
    } else {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _permissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized;

      if (_permissionGranted) {
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // This would ideally integrate with flutter_local_notifications for local display
          print('Received foreground message: ${message.notification?.title}');
        });

        // Get the device token for this installation
        try {
          final token = await messaging.getToken();
          print('FCM Device Token: $token');
          if (token != null) {
            await _sendTokenToBackend(token);
          }
        } catch (e) {
          print('Failed to get FCM token: $e');
        }
      }
    }

    _initialized = true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!_initialized) await initialize();

    if (kIsWeb) {
      try {
        if (!_permissionGranted) {
          _permissionGranted = await web_notif.requestWebNotificationPermission();
        }
        if (_permissionGranted) {
          web_notif.showWebNotification(title, body);
        }
      } catch (_) {}
    }
  }

  Future<void> cancelAll() async {}

  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
  }

  Future<int> get scheduledHour async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHour) ?? 9;
  }

  Future<int> get scheduledMinute async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMinute) ?? 0;
  }

  Future<void> setScheduledTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHour, hour);
    await prefs.setInt(_keyMinute, minute);
  }

  Future<bool> get fairEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFairEnabled) ?? false;
  }

  Future<bool> get stalledEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStalledEnabled) ?? true;
  }

  Future<bool> get criticalEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCriticalEnabled) ?? true;
  }

  Future<void> setTaskFilter({
    required bool fair,
    required bool stalled,
    required bool critical,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFairEnabled, fair);
    await prefs.setBool(_keyStalledEnabled, stalled);
    await prefs.setBool(_keyCriticalEnabled, critical);

    if (!kIsWeb) {
      final messaging = FirebaseMessaging.instance;
      if (fair) {
        await messaging.subscribeToTopic('topic_fair');
      } else {
        await messaging.unsubscribeFromTopic('topic_fair');
      }
      
      if (stalled) {
        await messaging.subscribeToTopic('topic_stalled');
      } else {
        await messaging.unsubscribeFromTopic('topic_stalled');
      }

      if (critical) {
        await messaging.subscribeToTopic('topic_critical');
      } else {
        await messaging.unsubscribeFromTopic('topic_critical');
      }
    }
  }

  Future<Map<String, bool>> getTaskFilters() async {
    return {
      'fair': await fairEnabled,
      'stalled': await stalledEnabled,
      'critical': await criticalEnabled,
    };
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final uri = Uri.parse('http://localhost:5000/api/users/device-token');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'device_token': token}),
      );
      print('Token successfully registered with backend proxy');
    } catch (e) {
      print('Failed to register token with backend: $e');
    }
  }
}
