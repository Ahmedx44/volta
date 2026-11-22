import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import 'common.dart';

class CircleIconButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: p.circle, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: HugeIcon(icon: icon, color: p.onCircle, size: 20),
        ),
      ),
    );
  }
}
