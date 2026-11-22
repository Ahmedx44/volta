import '../../../core/model/battery_snapshot.dart';

class BatteryHealth {
  final double percent;

  /// false = reported by the phone, true = calculated by the app.
  final bool isEstimated;

  const BatteryHealth({required this.percent, required this.isEstimated});

  String get label => isEstimated ? 'Estimated' : 'Reported by phone';
}

/// Below this level the charge counter is too imprecise to estimate from.
const int kMinPercentForEstimate = 50;

/// Uses the value Android reports when there is one (Android 14+ on phones
/// that support it). Otherwise estimates it from the charge counter.
BatteryHealth? computeBatteryHealth(BatterySnapshot s, int designMah) {
  final system = s.systemHealthPercent;
  if (system != null) {
    return BatteryHealth(percent: system.toDouble(), isEstimated: false);
  }

  if (designMah <= 0) return null;
  if (s.percent < kMinPercentForEstimate) return null;
  if (s.chargeMah <= 0) return null;

  final fullMah = s.chargeMah * 100 / s.percent;
  final health = (fullMah / designMah * 100).clamp(0.0, 100.0);
  return BatteryHealth(percent: health, isEstimated: true);
}
