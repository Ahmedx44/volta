import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../home/widet/common.dart';
import 'app_sheet.dart';

/// Explains that notifications are blocked and opens the system settings.
Future<void> showPermissionSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    title: 'Notifications are off',
    subtitle:
        'Volta needs notification permission to send alerts and to show that it is recording in the background.',
    builder: (sheetContext) => Column(
      children: [
        SheetButton(
          label: 'Open settings',
          onTap: () {
            Navigator.of(sheetContext).pop();
            openAppSettings();
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(sheetContext).pop(),
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                'Not now',
                style: vText(14, color: sheetContext.vc.textSecondary),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
