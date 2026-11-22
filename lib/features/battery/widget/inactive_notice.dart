import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../home/widet/common.dart';

/// Shown when the tab does not match what the phone is doing right now.
class InactiveNotice extends StatelessWidget {
  final bool forChargingTab;
  const InactiveNotice({super.key, required this.forChargingTab});

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return VCard(
      green: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          HugeIcon(
            icon: forChargingTab
                ? HugeIcons.strokeRoundedPlug01
                : HugeIcons.strokeRoundedBatteryCharging01,
            color: p.onGreen,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              forChargingTab
                  ? 'Unplugged. Live charging values appear when you plug in.'
                  : 'Plugged in. Discharge values appear when you unplug.',
              style: vText(13, color: p.onGreen),
            ),
          ),
        ],
      ),
    );
  }
}
