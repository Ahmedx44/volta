import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../home/widet/common.dart';
import '../../home/widet/info_row.dart';

class SettingsSwitchRow extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final bool value;
  final VoidCallback onToggle;
  final bool last;

  const SettingsSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onToggle,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return InfoRow(
      icon: icon,
      title: title,
      last: last,
      onTap: onToggle,
      trailing: _Switch(value: value, label: title),
    );
  }
}

class SettingsValueRow extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool last;

  const SettingsValueRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return InfoRow(
      icon: icon,
      title: title,
      last: last,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: vText(13.5, color: p.textSecondary)),
          const SizedBox(width: 2),
          HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            size: 14,
            color: p.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  final String label;
  const _Switch({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Semantics(
      toggled: value,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? p.accent : p.track,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
