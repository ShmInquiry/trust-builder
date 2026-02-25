import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
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
  }

  Future<Map<String, bool>> getTaskFilters() async {
    return {
      'fair': await fairEnabled,
      'stalled': await stalledEnabled,
      'critical': await criticalEnabled,
    };
  }
}
