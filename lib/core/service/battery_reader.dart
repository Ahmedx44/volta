import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';

import '../../android_battery.g.dart';
import '../model/battery_snapshot.dart';

class BatteryReader {
  Context? _context;
  BatteryManager? _manager;
  IntentFilter? _filter;
  final _keys = <String, JString>{};

  // BatteryManager.BATTERY_PROPERTY_STATE_OF_HEALTH (added in Android 14).
  // Used as a plain number so it works even if the generated bindings
  // were built against an older Android SDK.
  static const int _stateOfHealthProperty = 10;

  JString _key(String name) => _keys.putIfAbsent(name, () => name.toJString());

  Context _getContext() {
    return _context ??= androidApplicationContext.as(Context.type);
  }

  BatteryManager _getManager() {
    final existing = _manager;
    if (existing != null) return existing;

    final service = _getContext().getSystemService$1(
      'batterymanager'.toJString(),
    );

    final manager = service!.as(BatteryManager.type);
    _manager = manager;
    return manager;
  }

  IntentFilter _getFilter() {
    return _filter ??= IntentFilter()
      ..addAction('android.intent.action.BATTERY_CHANGED'.toJString());
  }

  BatterySnapshot read() {
    final m = _getManager();
    var charging = m.isCharging;
    int status = 1;

    double? temperatureC;
    int? voltageMv;
    int healthCode = 1;
    int plugged = 0;
    int? cycleCount;
    String? technology;

    final intent = _getContext().registerReceiver(null, _getFilter());
    if (intent != null) {
      try {
        final rawTemp = intent.getIntExtra(_key('temperature'), -1);
        final rawVolt = intent.getIntExtra(_key('voltage'), -1);
        if (rawTemp != -1) temperatureC = rawTemp / 10.0;
        if (rawVolt > 0) voltageMv = rawVolt;

        healthCode = intent.getIntExtra(_key('health'), 1);
        plugged = intent.getIntExtra(_key('plugged'), 0);
        status = intent.getIntExtra(_key('status'), 1);

        final rawCycles = intent.getIntExtra(
          _key('android.os.extra.CYCLE_COUNT'),
          -1,
        );
        if (rawCycles > 0) cycleCount = rawCycles;

        technology = intent
            .getStringExtra(_key('technology'))
            ?.toDartString(releaseOriginal: true);
      } finally {
        intent.release();
      }
    }

    // isCharging alone can be false on some phones while a charger is
    // connected, so also trust the plugged flags and the status code
    // (2 = charging, 5 = full while plugged in).
    if (plugged != 0 || status == 2 || status == 5) charging = true;

    int? chargeTimeMs;
    if (charging) {
      try {
        final ms = m.computeChargeTimeRemaining();
        if (ms > 0) chargeTimeMs = ms;
      } catch (_) {}
    }

    int? systemHealth;
    try {
      final v = m.getIntProperty(_stateOfHealthProperty);
      if (v > 0 && v <= 100) systemHealth = v;
    } catch (_) {}

    return BatterySnapshot(
      percent: m.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY),
      isCharging: charging,
      currentMicroAmps: m.getIntProperty(
        BatteryManager.BATTERY_PROPERTY_CURRENT_NOW,
      ),
      chargeCounterMicroAmpHours: m.getIntProperty(
        BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER,
      ),
      temperatureC: temperatureC,
      voltageMv: voltageMv,
      healthCode: healthCode,
      plugged: plugged,
      technology: technology,
      cycleCount: cycleCount,
      chargeTimeRemainingMs: chargeTimeMs,
      systemHealthPercent: systemHealth,
    );
  }

  void dispose() {
    _manager?.release();
    _filter?.release();
    _context?.release();
    for (final k in _keys.values) {
      k.release();
    }
    _keys.clear();
    _manager = null;
    _filter = null;
    _context = null;
  }
}
