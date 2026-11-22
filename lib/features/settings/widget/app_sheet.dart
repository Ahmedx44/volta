import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../home/widet/common.dart';

/// Opens a rounded bottom sheet with a drag handle, a title and [builder]'s
/// content. Works in light and dark mode and lifts above the keyboard.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget Function(BuildContext sheetContext) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0x00000000),
    barrierColor: const Color(0x99000000),
    builder: (sheetContext) {
      final p = sheetContext.vc;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: p.border, width: 0.8),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: VScope(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: p.track,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(title, style: vText(22, w: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: vText(13, color: p.textSecondary)),
                  ],
                  const SizedBox(height: 18),
                  builder(sheetContext),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Full-width green button used to confirm a sheet.
class SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const SheetButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.green,
          borderRadius: BorderRadius.circular(27),
        ),
        child: Text(
          label,
          style: vText(15, w: FontWeight.w500, color: p.onGreen),
        ),
      ),
    );
  }
}
