import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/widet/common.dart';
import '../../home/widet/current_graph_card.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../cubit/battery_cubit.dart';
import '../widget/inactive_notice.dart';
import '../widget/live_bento.dart';

/// Body of the Charging tab ([charging] true) and Battery tab (false).
class LiveStatsPage extends StatelessWidget {
  final bool charging;
  const LiveStatsPage({super.key, required this.charging});

  @override
  Widget build(BuildContext context) {
    final battery = context.watch<BatteryCubit>().state;
    final settings = context.watch<SettingsCubit>().state;

    final s = battery.snapshot;
    final active = s.isCharging == charging;
    final currentText = active ? '${s.currentMa} mA' : '--';

    final design = settings.designCapacityMah;
    final mahPerPercent = design / 100;
    final rate = battery.ratePerHour(design);
    final change = battery.sessionChange;
    final timeLeft = battery.timeLeft(design);
    final timeToFull = battery.timeToFull(design);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        if (!active) ...[
          InactiveNotice(forChargingTab: charging),
          const SizedBox(height: 12),
        ],
        LiveBento(
          charging: charging,
          active: active,
          snapshot: s,
          settings: settings,
        ),
        const SizedBox(height: 12),
        CurrentGraphCard(
          title: charging ? 'Charging current' : 'Discharge current',
          latest: currentText,
          values: List.of(battery.currentHistory),
        ),
        if (charging) ...[
          const SectionHeader(
            'Charging speed',
            subtitle: 'Average charge rate over the last 24 hours',
          ),
        ] else ...[
          const SectionHeader(
            'Time left',
            subtitle: 'Estimated from your recent average usage',
          ),
          TwoColumn([
            StatCard(
              'Remaining',
              timeLeft == null ? '--' : fmtDuration(timeLeft),
              timeLeft == null ? 'Unplug to see' : 'At current use',
            ),
            StatCard('Battery left', '${s.percent}%', '${s.chargeMah} mAh'),
          ]),
          const SectionHeader(
            'Drain speed',
            subtitle: 'Average battery drain right now',
          ),
        ],
        TwoColumn([
          StatCard(
            'Average rate',
            rate == null ? '--' : '${signed(rate)}%/h',
            rate == null
                ? 'No current reading'
                : '${signed(rate * mahPerPercent, digits: 0)} mAh/h',
          ),
          StatCard(
            charging ? 'Charged' : 'Used',
            !active || change == 0 ? '--' : '${signed(change, digits: 0)}%',
            !active || change == 0
                ? 'Since plugged in or app opened'
                : '${(change.abs() * mahPerPercent).round()} mAh this session',
          ),
        ]),
        if (charging) ...[
          const SectionHeader(
            'Details',
            subtitle: 'Live information from your phone',
          ),
          TwoColumn([
            StatCard(
              'Time to full',
              timeToFull == null ? '--' : fmtDuration(timeToFull.time),
              timeToFull == null
                  ? 'Plug in to see'
                  : timeToFull.estimated
                  ? 'Estimated from current'
                  : 'Reported by phone',
            ),
            StatCard(
              'Power source',
              s.powerSource,
              s.isCharging ? 'Charging' : 'On battery',
            ),
          ]),
        ],
      ],
    );
  }
}
