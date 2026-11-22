import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../battery/cubit/battery_cubit.dart';
import '../../home/widet/battery_heatlh.dart';
import '../../home/widet/common.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../widget/health_ring.dart';
import '../widget/health_trend_chart.dart';

/// Health tab body.
class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  static String _rating(double? percent) {
    if (percent == null) return 'Unknown';
    if (percent >= 80) return 'Good';
    if (percent >= 60) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    final battery = context.watch<BatteryCubit>().state;
    final settings = context.watch<SettingsCubit>().state;

    final s = battery.snapshot;
    final design = settings.designCapacityMah;
    final health = computeBatteryHealth(s, design);
    final percent = health?.percent;
    final currentMah = percent == null
        ? null
        : (design * percent / 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        VCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  HealthRing(percent: percent),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Battery health',
                          style: vText(13, color: p.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _rating(percent),
                          style: vText(22, w: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          health == null
                              ? 'Charge above $kMinPercentForEstimate% to get an estimate.'
                              : '${health.label}. Holds less charge than when new; this is normal with age.',
                          style: vText(11.5, color: p.textFaint),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _CapacityBar(current: currentMah, design: design),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TwoColumn([
          StatCard('Design capacity', '$design', 'mAh when new'),
          StatCard(
            'Current capacity',
            currentMah?.toString() ?? '--',
            'mAh estimated',
            green: true,
          ),
          StatCard(
            'Charge cycles',
            s.cycleCount?.toString() ?? '--',
            s.cycleCount == null ? 'Android 14+ only' : 'Since first use',
          ),
          StatCard(
            'Condition',
            s.condition,
            s.healthCode == 2 ? 'No overheating' : 'Reported by phone',
          ),
        ]),
        const SectionHeader('Health over time'),
        VCard(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: HealthTrendChart(healthByMonth: battery.history.healthByMonth),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
          child: Text(
            'Capacity is estimated from the charge counter, so it can vary a little between readings.',
            style: vText(12, color: p.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _CapacityBar extends StatelessWidget {
  final int? current;
  final int design;
  const _CapacityBar({required this.current, required this.design});

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    final f = current == null ? 0.0 : (current! / design).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Capacity', style: vText(12, color: p.textSecondary)),
            Text('${current ?? '--'} / $design mAh', style: vText(12)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: p.accentSoft,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: f,
            child: Container(
              decoration: BoxDecoration(
                color: p.green,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
