import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/model/battery_snapshot.dart';
import '../../home/widet/metric_card.dart';
import '../../home/widet/wave_level_card.dart';
import '../../settings/cubit/settings_state.dart';

/// Two-column bento of live cards at the top of Charging / Battery.
class LiveBento extends StatelessWidget {
  final bool charging;
  final bool active;
  final BatterySnapshot snapshot;
  final SettingsState settings;

  const LiveBento({
    super.key,
    required this.charging,
    required this.active,
    required this.snapshot,
    required this.settings,
  });

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final s = snapshot;
    final power = !active || s.powerWatts == null
        ? '--'
        : '${s.powerWatts!.toStringAsFixed(1)} W';

    return SizedBox(
      height: 500,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 160,
                  child: MetricCard(
                    title: charging ? 'Charge current' : 'Discharge current',
                    value: active ? '${s.currentMa} mA' : '--',
                    icon: HugeIcons.strokeRoundedFlash,
                    highlighted: true,
                  ),
                ),
                const SizedBox(height: _gap),
                Expanded(
                  flex: 150,
                  child: MetricCard(
                    title: 'Temperature',
                    value: settings.formatTemperature(s.temperatureC),
                    icon: HugeIcons.strokeRoundedThermometer,
                  ),
                ),
                const SizedBox(height: _gap),
                Expanded(
                  flex: 150,
                  child: MetricCard(
                    title: 'Voltage',
                    value: s.voltageMv == null ? '--' : '${s.voltageMv} mV',
                    icon: HugeIcons.strokeRoundedPlug01,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: MetricCard(
                    title: charging ? 'Charging speed' : 'Power use',
                    value: power,
                    icon: HugeIcons.strokeRoundedActivity01,
                  ),
                ),
                const SizedBox(height: _gap),
                Expanded(
                  child: WaveLevelCard(
                    percent: s.percent,
                    chargeMah: s.chargeMah,
                    designMah: settings.designCapacityMah,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
