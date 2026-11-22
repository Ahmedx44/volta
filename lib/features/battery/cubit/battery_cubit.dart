import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/alert_engine.dart';
import '../../../core/service/background_monitor.dart';
import '../../../core/service/battery_reader.dart';
import '../../../core/service/history_store.dart';
import '../../../core/service/notification_service.dart';
import '../../home/widet/battery_heatlh.dart';
import '../../settings/cubit/settings_cubit.dart';
import 'battery_state.dart';

/// Reads the battery every few seconds and records long-term history.
class BatteryCubit extends Cubit<BatteryState> {
  BatteryCubit(SettingsCubit settings)
    : this._(settings, BatteryReader(), HistoryStore());

  BatteryCubit._(this._settings, BatteryReader reader, HistoryStore history)
    : _reader = reader,
      _history = history,
      super(_initial(reader, history)) {
    NotificationService.instance.init();
    history.load().then((_) {
      _tick();
      _refreshService();
    });
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _tick());
  }

  static BatteryState _initial(BatteryReader reader, HistoryStore history) {
    final snapshot = reader.read();
    return BatteryState(
      snapshot: snapshot,
      currentHistory: [snapshot.currentMa.toDouble()],
      history: history,
      sessionStartPercent: snapshot.percent,
    );
  }

  static const _maxGraphPoints = 40;

  final SettingsCubit _settings;
  final BatteryReader _reader;
  final HistoryStore _history;
  final _alerts = AlertEngine();
  Timer? _timer;
  int _ticks = 0;

  /// While the background service runs it records history and sends alerts,
  /// so the app only reads from disk to avoid doing it twice.
  bool _serviceRunning = false;

  void _tick() {
    if (isClosed) return;
    final snapshot = _reader.read();
    final settings = _settings.state;

    final graph = [...state.currentHistory, snapshot.currentMa.toDouble()];
    if (graph.length > _maxGraphPoints) graph.removeAt(0);

    final plugChanged = snapshot.isCharging != state.snapshot.isCharging;

    if (!_serviceRunning) {
      final health = computeBatteryHealth(snapshot, settings.designCapacityMah);
      _history.record(
        snapshot.percent,
        snapshot.isCharging,
        every: Duration(minutes: settings.sampleEveryMinutes),
        keepDays: settings.keepHistoryDays,
        healthPercent: health?.percent.round(),
      );
      _alerts.check(snapshot, settings);
    }

    emit(
      state.copyWith(
        snapshot: snapshot,
        currentHistory: graph,
        sessionStartPercent: plugChanged ? snapshot.percent : null,
      ),
    );

    if (++_ticks % 5 == 0) _refreshService();
  }

  Future<void> _refreshService() async {
    _serviceRunning = await BackgroundMonitor.isRunning;
    if (_serviceRunning && !isClosed) await _history.reload();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _history.flush();
    _reader.dispose();
    return super.close();
  }
}
