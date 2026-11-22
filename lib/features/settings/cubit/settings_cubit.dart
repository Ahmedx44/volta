import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/service/background_monitor.dart';
import '../../../core/service/notification_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const sampleOptions = [1, 5, 15, 30];
  static const keepOptions = [7, 30, 90, 365];

  SharedPreferences? _prefs;

  Future<void> load() async {
    final p = _prefs = await SharedPreferences.getInstance();
    emit(SettingsState.fromPrefs(p));
    // The service does not survive every restart, so bring it back.
    if (state.runInBackground) await BackgroundMonitor.start();
  }

  // Alerts need notification permission. These return false when the user
  // refuses, and the switch stays off.

  Future<bool> toggleChargeLimitAlert() => _toggleAlert(
    state.chargeLimitAlert,
    (v) => state.copyWith(chargeLimitAlert: v),
  );

  Future<bool> toggleLowBatteryAlert() => _toggleAlert(
    state.lowBatteryAlert,
    (v) => state.copyWith(lowBatteryAlert: v),
  );

  Future<bool> toggleOverheatWarning() => _toggleAlert(
    state.overheatWarning,
    (v) => state.copyWith(overheatWarning: v),
  );

  Future<bool> _toggleAlert(
    bool current,
    SettingsState Function(bool) apply,
  ) async {
    if (!current && !await NotificationService.instance.ensurePermission()) {
      return false;
    }
    _set(apply(!current));
    return true;
  }

  /// Turns the background service on or off. Returns false if it could not
  /// start (for example notifications are blocked).
  Future<bool> toggleRunInBackground() async {
    if (state.runInBackground) {
      _set(state.copyWith(runInBackground: false));
      await BackgroundMonitor.stop();
      return true;
    }
    if (!await NotificationService.instance.ensurePermission()) return false;
    if (!await BackgroundMonitor.start()) return false;
    _set(state.copyWith(runInBackground: true));
    return true;
  }

  void setAlertAt(int percent) {
    _set(state.copyWith(alertAt: percent.clamp(50, 100)));
  }

  void setSampleInterval(int minutes) {
    _set(state.copyWith(sampleEveryMinutes: minutes));
  }

  void setKeepHistory(int days) {
    _set(state.copyWith(keepHistoryDays: days));
  }

  void setFahrenheit(bool value) {
    _set(state.copyWith(useFahrenheit: value));
  }

  void setThemeMode(AppThemeMode mode) {
    _set(state.copyWith(themeMode: mode));
  }

  /// Ignores values outside a believable phone-battery range.
  void setDesignCapacity(int mah) {
    if (mah < 500 || mah > 20000) return;
    _set(state.copyWith(designCapacityMah: mah));
  }

  void _set(SettingsState next) {
    emit(next);
    final p = _prefs;
    if (p != null) next.saveTo(p);
  }
}
