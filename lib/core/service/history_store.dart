import 'package:shared_preferences/shared_preferences.dart';

class LevelSample {
  final DateTime time;
  final int percent;
  final bool charging;
  const LevelSample(this.time, this.percent, this.charging);
}

class ChargeSession {
  final DateTime start;
  final Duration duration;
  final int gained;
  const ChargeSession(this.start, this.duration, this.gained);
}

/// Level samples (persisted) and a monthly health log.
class HistoryStore {
  static const _samplesKey = 'h_samples';
  static const _healthKey = 'h_health';

  SharedPreferences? _prefs;
  final samples = <LevelSample>[];
  final healthByMonth = <String, int>{}; // 'yyyy-MM' -> percent
  DateTime? _lastSaved;
  bool isLoaded = false;

  /// Re-reads from disk (the background service writes to the same storage).
  Future<void> reload() async {
    final p = await SharedPreferences.getInstance();
    await p.reload();
    await load();
  }

  Future<void> load() async {
    final p = _prefs = await SharedPreferences.getInstance();
    samples.clear();
    healthByMonth.clear();
    for (final raw in p.getStringList(_samplesKey) ?? const <String>[]) {
      final parts = raw.split(',');
      if (parts.length != 3) continue;
      final ms = int.tryParse(parts[0]);
      final pct = int.tryParse(parts[1]);
      if (ms == null || pct == null) continue;
      samples.add(
        LevelSample(
          DateTime.fromMillisecondsSinceEpoch(ms),
          pct,
          parts[2] == '1',
        ),
      );
    }
    for (final raw in p.getStringList(_healthKey) ?? const <String>[]) {
      final parts = raw.split('=');
      final v = parts.length == 2 ? int.tryParse(parts[1]) : null;
      if (v != null) healthByMonth[parts[0]] = v;
    }
    samples.sort((a, b) => a.time.compareTo(b.time));
    isLoaded = true;
  }

  /// Writes everything to disk now (used when the app closes).
  void flush() {
    _lastSaved = null;
    _save();
  }

  /// Adds a sample when [every] has passed since the last one.
  void record(
    int percent,
    bool charging, {
    required Duration every,
    required int keepDays,
    int? healthPercent,
  }) {
    if (!isLoaded) return; // loading would otherwise put old samples after new
    final now = DateTime.now();
    if (healthPercent != null) {
      healthByMonth[_month(now)] = healthPercent;
    }
    final last = samples.isEmpty ? null : samples.last.time;
    if (last != null && now.difference(last) < every) return;

    samples.add(LevelSample(now, percent, charging));
    final cutoff = now.subtract(Duration(days: keepDays));
    samples.removeWhere((s) => s.time.isBefore(cutoff));
    _save();
  }

  static String _month(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  void _save() {
    final p = _prefs;
    if (p == null) return;
    final now = DateTime.now();
    if (_lastSaved != null &&
        now.difference(_lastSaved!) < const Duration(minutes: 1)) {
      return;
    }
    _lastSaved = now;
    p.setStringList(_samplesKey, [
      for (final s in samples)
        '${s.time.millisecondsSinceEpoch},${s.percent},${s.charging ? 1 : 0}',
    ]);
    p.setStringList(_healthKey, [
      for (final e in healthByMonth.entries) '${e.key}=${e.value}',
    ]);
  }

  List<LevelSample> within(Duration d) {
    final cutoff = DateTime.now().subtract(d);
    return samples.where((s) => s.time.isAfter(cutoff)).toList();
  }

  List<ChargeSession> sessions() {
    final out = <ChargeSession>[];
    var run = <LevelSample>[];
    void close() {
      if (run.length > 1) {
        final gain = run.last.percent - run.first.percent;
        if (gain > 0) {
          out.add(
            ChargeSession(
              run.first.time,
              run.last.time.difference(run.first.time),
              gain,
            ),
          );
        }
      }
      run = [];
    }

    for (final s in samples) {
      if (s.charging) {
        run.add(s);
      } else {
        close();
      }
    }
    close();
    return out.reversed.toList();
  }

  /// Average %/hour across charging or discharging samples.
  double? ratePerHour({
    required bool charging,
    Duration window = const Duration(hours: 24),
  }) {
    final list = within(window);
    var pct = 0.0;
    var hours = 0.0;
    for (var i = 1; i < list.length; i++) {
      final a = list[i - 1], b = list[i];
      if (a.charging != charging || b.charging != charging) continue;
      final dt = b.time.difference(a.time).inSeconds / 3600;
      if (dt <= 0 || dt > 0.5) continue; // skip gaps
      pct += (b.percent - a.percent);
      hours += dt;
    }
    return hours < 0.05 ? null : pct / hours;
  }

  /// Total percent gained (charging) or used (discharging) over [window].
  int totalChange({
    required bool charging,
    Duration window = const Duration(hours: 24),
  }) {
    final list = within(window);
    var total = 0;
    for (var i = 1; i < list.length; i++) {
      final a = list[i - 1], b = list[i];
      if (a.charging != charging || b.charging != charging) continue;
      final d = b.percent - a.percent;
      if (charging ? d > 0 : d < 0) total += d.abs();
    }
    return total;
  }
}
