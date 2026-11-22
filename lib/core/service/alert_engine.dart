import '../../features/settings/cubit/settings_state.dart';
import '../model/battery_snapshot.dart';
import 'notification_service.dart';

/// Decides when to notify. Each alert fires once, then re-arms after the
/// condition clears, so it never repeats every few seconds.
class AlertEngine {
  AlertEngine([NotificationService? notifications])
    : _notifications = notifications ?? NotificationService.instance;

  final NotificationService _notifications;

  static const _chargeId = 101;
  static const _lowId = 102;
  static const _heatId = 103;

  static const _lowLevel = 20;
  static const _heatOn = 45.0;
  static const _heatOff = 42.0;

  bool _chargeSent = false;
  bool _lowSent = false;
  bool _heatSent = false;

  Future<void> check(BatterySnapshot s, SettingsState settings) async {
    // Charge limit: reached while charging.
    if (settings.chargeLimitAlert &&
        s.isCharging &&
        s.percent >= settings.alertAt) {
      if (!_chargeSent) {
        _chargeSent = true;
        await _notifications.show(
          _chargeId,
          'Battery at ${s.percent}%',
          'Reached your ${settings.alertAt}% limit. You can unplug now.',
        );
      }
    } else if (!s.isCharging || s.percent < settings.alertAt - 3) {
      _chargeSent = false;
    }

    // Low battery: at or under the threshold and not charging.
    if (settings.lowBatteryAlert && !s.isCharging && s.percent <= _lowLevel) {
      if (!_lowSent) {
        _lowSent = true;
        await _notifications.show(
          _lowId,
          'Battery low: ${s.percent}%',
          'Plug in your charger soon.',
        );
      }
    } else if (s.isCharging || s.percent > _lowLevel + 5) {
      _lowSent = false;
    }

    // Overheat: warm threshold with hysteresis.
    final t = s.temperatureC;
    if (settings.overheatWarning && t != null && t >= _heatOn) {
      if (!_heatSent) {
        _heatSent = true;
        await _notifications.show(
          _heatId,
          'Battery is hot: ${settings.formatTemperature(t)}',
          'Stop charging or close heavy apps to let it cool down.',
        );
      }
    } else if (t == null || t <= _heatOff) {
      _heatSent = false;
    }
  }
}
