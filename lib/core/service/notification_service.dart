import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper over flutter_local_notifications for Volta's alerts.
/// Safe to use from the app and from the background service isolate.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'volta_alerts',
    'Battery alerts',
    channelDescription: 'Charge limit, low battery and overheat warnings',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> init() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  /// True if notifications are allowed (asks on Android 13+ if not yet).
  Future<bool> ensurePermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    if (await android.areNotificationsEnabled() ?? false) return true;
    return await android.requestNotificationsPermission() ?? false;
  }

  Future<bool> get isEnabled async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? true;
  }

  Future<void> show(int id, String title, String body) async {
    await init();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: _channel),
    );
  }
}
