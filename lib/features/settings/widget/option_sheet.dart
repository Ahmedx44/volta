import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../home/widet/common.dart';
import 'app_sheet.dart';

class SheetOption<T> {
  final T value;
  final String label;
  final String? description;
  const SheetOption(this.value, this.label, {this.description});
}

/// Bottom sheet that lets the user pick one of [options]. Tapping an option
/// closes the sheet and returns its value.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<SheetOption<T>> options,
  required T selected,
}) {
  return showAppSheet<T>(
    context,
    title: title,
    subtitle: subtitle,
    builder: (sheetContext) => Column(
      children: [
        for (final o in options)
          _OptionTile(
            option: o,
            selected: o.value == selected,
            onTap: () => Navigator.of(sheetContext).pop(o.value),
          ),
      ],
    ),
  );
}

class _OptionTile<T> extends StatelessWidget {
  final SheetOption<T> option;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? p.accentSoft : p.page,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? p.accent : p.border,
            width: selected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: vText(
                      15,
                      w: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  if (option.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      option.description!,
                      style: vText(12, color: p.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              HugeIcon(
                icon: HugeIcons.strokeRoundedTick02,
                size: 20,
                color: p.accent,
              ),
          ],
        ),
      ),
    );
  }
}
