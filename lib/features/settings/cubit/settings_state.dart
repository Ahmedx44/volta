import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system('System'),
  light('Light'),
  dark('Dark');

  final String label;
  const AppThemeMode(this.label);
}

class SettingsState {
  final bool chargeLimitAlert;
  final int alertAt;
  final bool lowBatteryAlert;
  final bool overheatWarning;
  final int sampleEveryMinutes;
  final int keepHistoryDays;
  final bool runInBackground;
  final bool useFahrenheit;
  final int designCapacityMah;
  final AppThemeMode themeMode;

  const SettingsState({
    this.chargeLimitAlert = true,
    this.alertAt = 80,
    this.lowBatteryAlert = true,
    this.overheatWarning = false,
    this.sampleEveryMinutes = 1,
    this.keepHistoryDays = 30,
    this.runInBackground = true,
    this.useFahrenheit = false,
    this.designCapacityMah = 4830,
    this.themeMode = AppThemeMode.system,
  });

  /// Reads saved settings. Missing values fall back to the defaults.
  factory SettingsState.fromPrefs(SharedPreferences p) {
    const d = SettingsState();
    return SettingsState(
      chargeLimitAlert: p.getBool('s_chargeLimitAlert') ?? d.chargeLimitAlert,
      alertAt: p.getInt('s_alertAt') ?? d.alertAt,
      lowBatteryAlert: p.getBool('s_lowBatteryAlert') ?? d.lowBatteryAlert,
      overheatWarning: p.getBool('s_overheatWarning') ?? d.overheatWarning,
      sampleEveryMinutes: p.getInt('s_sampleEvery') ?? d.sampleEveryMinutes,
      keepHistoryDays: p.getInt('s_keepDays') ?? d.keepHistoryDays,
      runInBackground: p.getBool('s_background') ?? d.runInBackground,
      useFahrenheit: p.getBool('s_fahrenheit') ?? d.useFahrenheit,
      designCapacityMah: p.getInt('s_design') ?? d.designCapacityMah,
      themeMode:
          AppThemeMode.values[(p.getInt('s_theme') ?? 0).clamp(
            0,
            AppThemeMode.values.length - 1,
          )],
    );
  }

  /// Writes every field to [p].
  Future<void> saveTo(SharedPreferences p) async {
    await p.setBool('s_chargeLimitAlert', chargeLimitAlert);
    await p.setInt('s_alertAt', alertAt);
    await p.setBool('s_lowBatteryAlert', lowBatteryAlert);
    await p.setBool('s_overheatWarning', overheatWarning);
    await p.setInt('s_sampleEvery', sampleEveryMinutes);
    await p.setInt('s_keepDays', keepHistoryDays);
    await p.setBool('s_background', runInBackground);
    await p.setBool('s_fahrenheit', useFahrenheit);
    await p.setInt('s_design', designCapacityMah);
    await p.setInt('s_theme', themeMode.index);
  }

  bool get anyAlertOn => chargeLimitAlert || lowBatteryAlert || overheatWarning;

  SettingsState copyWith({
    bool? chargeLimitAlert,
    int? alertAt,
    bool? lowBatteryAlert,
    bool? overheatWarning,
    int? sampleEveryMinutes,
    int? keepHistoryDays,
    bool? runInBackground,
    bool? useFahrenheit,
    int? designCapacityMah,
    AppThemeMode? themeMode,
  }) {
    return SettingsState(
      chargeLimitAlert: chargeLimitAlert ?? this.chargeLimitAlert,
      alertAt: alertAt ?? this.alertAt,
      lowBatteryAlert: lowBatteryAlert ?? this.lowBatteryAlert,
      overheatWarning: overheatWarning ?? this.overheatWarning,
      sampleEveryMinutes: sampleEveryMinutes ?? this.sampleEveryMinutes,
      keepHistoryDays: keepHistoryDays ?? this.keepHistoryDays,
      runInBackground: runInBackground ?? this.runInBackground,
      useFahrenheit: useFahrenheit ?? this.useFahrenheit,
      designCapacityMah: designCapacityMah ?? this.designCapacityMah,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  String formatTemperature(double? celsius) {
    if (celsius == null) return '--';
    return useFahrenheit
        ? '${(celsius * 9 / 5 + 32).toStringAsFixed(1)}°F'
        : '${celsius.toStringAsFixed(1)}°C';
  }
}
