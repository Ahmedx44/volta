import '../../../core/model/battery_snapshot.dart';
import '../../../core/service/history_store.dart';

class BatteryState {
  final BatterySnapshot snapshot;

  /// Recent current readings (mA) for the live graph.
  final List<double> currentHistory;

  /// Long-term samples. Mutated in place; [BatteryState] is re-emitted on each
  /// reading so listeners rebuild.
  final HistoryStore history;

  /// Battery percent when the app opened or the charger was last
  /// plugged/unplugged.
  final int sessionStartPercent;

  const BatteryState({
    required this.snapshot,
    required this.currentHistory,
    required this.history,
    required this.sessionStartPercent,
  });

  /// Percent gained (positive) or used (negative) in the current session.
  int get sessionChange => snapshot.percent - sessionStartPercent;

  BatteryState copyWith({
    BatterySnapshot? snapshot,
    List<double>? currentHistory,
    int? sessionStartPercent,
  }) {
    return BatteryState(
      snapshot: snapshot ?? this.snapshot,
      currentHistory: currentHistory ?? this.currentHistory,
      history: history,
      sessionStartPercent: sessionStartPercent ?? this.sessionStartPercent,
    );
  }

  /// Average %/hour: from recorded history when there is enough, otherwise
  /// worked out from the current being drawn right now.
  /// Positive while charging, negative while discharging.
  double? ratePerHour(int designMah) {
    final charging = snapshot.isCharging;
    final fromHistory = history.ratePerHour(charging: charging);
    if (fromHistory != null && fromHistory.abs() > 0.1) return fromHistory;

    final ma = snapshot.currentMa;
    if (ma <= 0 || designMah <= 0) return null;
    final live = ma / designMah * 100;
    return charging ? live : -live;
  }

  /// Time until 100%: the phone's own figure, else estimated from current.
  ({Duration time, bool estimated})? timeToFull(int designMah) {
    if (!snapshot.isCharging) return null;
    final ms = snapshot.chargeTimeRemainingMs;
    if (ms != null) return (time: Duration(milliseconds: ms), estimated: false);

    final ma = snapshot.currentMa;
    if (ma < 50 || designMah <= 0) return null;
    final hours = designMah * (100 - snapshot.percent) / 100 / ma;
    return (time: Duration(minutes: (hours * 60).round()), estimated: true);
  }

  /// Time until empty at the current drain rate.
  Duration? timeLeft(int designMah) {
    if (snapshot.isCharging) return null;
    final ma = snapshot.currentMa;
    if (ma < 20 || designMah <= 0) return null;
    final hours = designMah * snapshot.percent / 100 / ma;
    return Duration(minutes: (hours * 60).round());
  }
}
