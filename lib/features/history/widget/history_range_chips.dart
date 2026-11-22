import 'package:flutter/widgets.dart';

import '../../home/widet/common.dart';
import '../cubit/history_state.dart';

class HistoryRangeChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const HistoryRangeChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
      child: Row(
        children: [
          for (final r in HistoryRange.values) ...[
            GestureDetector(
              onTap: () => onSelected(r.index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: r.index == selected ? p.green : p.accentSoft,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Text(
                  r.label,
                  style: vText(
                    12.5,
                    w: r.index == selected ? FontWeight.w500 : FontWeight.w400,
                    color: r.index == selected ? p.onGreen : p.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
