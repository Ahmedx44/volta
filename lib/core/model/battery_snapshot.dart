class BatterySnapshot {
  final int percent;
  final bool isCharging;
  final int currentMicroAmps;
  final int chargeCounterMicroAmpHours;

  final double? temperatureC;
  final int? voltageMv;

  /// BatteryManager.BATTERY_HEALTH_* code (2 = good, 3 = overheat ...).
  final int healthCode;

  /// Bitmask: 1 = AC, 2 = USB, 4 = wireless, 8 = dock. 0 = on battery.
  final int plugged;

  final String? technology;
  final int? cycleCount;
  final int? chargeTimeRemainingMs;

  /// Health percent reported by Android 14+ (null if not supported).
  final int? systemHealthPercent;

  const BatterySnapshot({
    required this.percent,
    required this.isCharging,
    required this.currentMicroAmps,
    required this.chargeCounterMicroAmpHours,
    this.temperatureC,
    this.voltageMv,
    this.healthCode = 1,
    this.plugged = 0,
    this.technology,
    this.cycleCount,
    this.chargeTimeRemainingMs,
    this.systemHealthPercent,
  });

  /// Android documents CURRENT_NOW in microamps, but some phones report
  /// milliamps. Real currents are never below ~10 mA while the app is open, so
  /// a raw value under 10000 is treated as already being in mA.
  int get currentMa {
    final raw = currentMicroAmps.abs();
    return raw < 10000 ? raw : raw ~/ 1000;
  }

  int get chargeMah => chargeCounterMicroAmpHours ~/ 1000;

  double? get powerWatts {
    final v = voltageMv;
    if (v == null) return null;
    return currentMa * v / 1000000;
  }

  String get powerSource {
    if (plugged & 1 != 0) return 'AC';
    if (plugged & 2 != 0) return 'USB';
    if (plugged & 4 != 0) return 'Wireless';
    if (plugged & 8 != 0) return 'Dock';
    return 'Battery';
  }

  String get condition {
    switch (healthCode) {
      case 2:
        return 'Good';
      case 3:
        return 'Overheat';
      case 4:
        return 'Dead';
      case 5:
        return 'Over voltage';
      case 6:
        return 'Failure';
      case 7:
        return 'Cold';
      default:
        return 'Unknown';
    }
  }
}
