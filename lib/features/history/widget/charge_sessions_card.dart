import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/service/history_store.dart';
import '../../home/widet/common.dart';
import '../../home/widet/info_row.dart';

class ChargeSessionsCard extends StatelessWidget {
  final List<ChargeSession> sessions;
  const ChargeSessionsCard({super.key, required this.sessions});

  static String _when(DateTime t) {
    final now = DateTime.now();
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(t.year, t.month, t.day)).inDays;
    final hm =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (days == 0) return 'Today, $hm';
    if (days == 1) return 'Yesterday, $hm';
    return '${t.day}/${t.month}, $hm';
  }

  @override
  Widget build(BuildContext context) {
    return VCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: sessions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No charge sessions recorded yet.',
                style: vText(13, color: context.vc.textSecondary),
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < sessions.length; i++)
                  InfoRow(
                    icon: HugeIcons.strokeRoundedBatteryCharging01,
                    title: _when(sessions[i].start),
                    last: i == sessions.length - 1,
                    trailing: Text(
                      '+${sessions[i].gained}% · ${fmtDuration(sessions[i].duration)}',
                      style: vText(
                        13,
                        w: FontWeight.w500,
                        color: context.vc.accent,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
