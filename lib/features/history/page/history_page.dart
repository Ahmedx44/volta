import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../battery/cubit/battery_cubit.dart';
import '../../home/widet/common.dart';
import '../cubit/history_cubit.dart';
import '../widget/charge_sessions_card.dart';
import '../widget/history_range_chips.dart';
import '../widget/level_area_chart.dart';

/// History tab body. Owns its own range selection via [HistoryCubit].
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final history = context.watch<BatteryCubit>().state.history;
    final range = context.watch<HistoryCubit>().state;

    final since = DateTime.now().subtract(range.range);
    final sessions = history
        .sessions()
        .where((s) => s.start.isAfter(since))
        .take(6)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        HistoryRangeChips(
          selected: range.rangeIndex,
          onSelected: context.read<HistoryCubit>().selectRange,
        ),
        VCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Battery level',
                style: vText(13, color: context.vc.textSecondary),
              ),
              const SizedBox(height: 8),
              LevelAreaChart(
                samples: history.within(range.range),
                span: range.range,
              ),
            ],
          ),
        ),
        const SectionHeader('Charge sessions'),
        ChargeSessionsCard(sessions: sessions),
      ],
    );
  }
}
