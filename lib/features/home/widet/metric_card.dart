import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import 'common.dart';

/// Tall bento card: title, big value, optional subtitle, icon at the bottom.
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final List<List<dynamic>> icon;
  final bool highlighted;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    final main = highlighted ? p.onGreen : p.text;
    final soft = highlighted ? p.onGreen : p.textSecondary;

    return VCard(
      green: highlighted,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: vText(13, color: soft)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: vText(26, w: FontWeight.w500, color: main),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: vText(11.5, color: soft)),
          ],
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: highlighted ? const Color(0x331F3D2A) : p.accentSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: HugeIcon(
              icon: icon,
              size: 20,
              color: highlighted ? p.onGreen : p.accent,
            ),
          ),
        ],
      ),
    );
  }
}
