import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/cubit/settings_state.dart';
import '../../features/home/widet/battery_heatlh.dart';
import 'alert_engine.dart';
import 'battery_reader.dart';
import 'history_store.dart';
import 'notification_service.dart';

/// Starts and stops the Android foreground service that keeps recording
/// history and sending alerts while the app is closed.
class BackgroundMonitor {
  BackgroundMonitor._();

  static bool _initialized = false;

  static void _init() {
    if (_initialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'volta_monitor',
        channelName: 'Battery recording',
        channelDescription:
            'Shown while Volta records your battery in the background',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(15000),
        allowWakeLock: true,
      ),
    );
    _initialized = true;
  }

  static Future<bool> get isRunning => FlutterForegroundTask.isRunningService;

  /// Returns true if the service is running afterwards.
  static Future<bool> start() async {
    _init();
    if (await isRunning) return true;
    final result = await FlutterForegroundTask.startService(
      serviceId: 4301,
      notificationTitle: 'Volta is recording',
      notificationText: 'Watching your battery in the background',
      callback: monitorCallback,
    );
    return result is ServiceRequestSuccess;
  }

  static Future<void> stop() async {
    if (await isRunning) await FlutterForegroundTask.stopService();
  }
}

@pragma('vm:entry-point')
void monitorCallback() {
  FlutterForegroundTask.setTaskHandler(_MonitorHandler());
}

/// Runs inside the service isolate. Reads settings from disk every tick, so
/// changes made in the app apply without restarting the service.
class _MonitorHandler extends TaskHandler {
  BatteryReader? _reader;
  final _history = HistoryStore();
  final _alerts = AlertEngine();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await NotificationService.instance.init();
    await _history.load();
    _reader = BatteryReader();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _tick();
  }

  Future<void> _tick() async {
    final reader = _reader;
    if (reader == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final settings = SettingsState.fromPrefs(prefs);

    final s = reader.read();
    final health = computeBatteryHealth(s, settings.designCapacityMah);
    _history.record(
      s.percent,
      s.isCharging,
      every: Duration(minutes: settings.sampleEveryMinutes),
      keepDays: settings.keepHistoryDays,
      healthPercent: health?.percent.round(),
    );
    await _alerts.check(s, settings);

    FlutterForegroundTask.updateService(
      notificationText:
          '${s.percent}% · ${s.isCharging ? 'Charging' : 'On battery'}',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _history.flush();
    _reader?.dispose();
    _reader = null;
  }
}
