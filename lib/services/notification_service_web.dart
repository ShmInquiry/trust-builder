import 'dart:js_interop';
import 'package:web/web.dart' as web;

bool checkWebNotificationSupport() {
  try {
    return web.Notification.permission.isNotEmpty;
  } catch (_) {
    return false;
  }
}

Future<bool> requestWebNotificationPermission() async {
  try {
    final permission = web.Notification.permission;
    if (permission == 'granted') return true;
    if (permission == 'denied') return false;
    final result = await web.Notification.requestPermission().toDart;
    return result == 'granted';
  } catch (_) {
    return false;
  }
}

void showWebNotification(String title, String body) {
  try {
    final options = web.NotificationOptions(body: body);
    web.Notification(title, options);
  } catch (_) {}
}
