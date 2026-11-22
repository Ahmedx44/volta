import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import 'common.dart';

/// Icon + title + trailing widget, used for list rows in cards.
class InfoRow extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final Widget trailing;
  final bool last;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.last = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: p.border, width: 0.8)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: p.accentSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: HugeIcon(icon: icon, size: 20, color: p.accent),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: vText(14.5))),
            trailing,
          ],
        ),
      ),
    );
  }
}
