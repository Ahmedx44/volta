import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../home/widet/common.dart';

class HealthRing extends StatelessWidget {
  final double? percent;
  const HealthRing({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return SizedBox(
      width: 112,
      height: 112,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: ((percent ?? 0) / 100).clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          painter: _RingPainter(t, p),
          child: Center(
            child: Text(
              percent == null ? '--' : '${percent!.round()}%',
              style: vText(24, w: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final VPalette p;
  const _RingPainter(this.fraction, this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint..color = p.accentSoft);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      paint..color = p.accent,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.fraction != fraction || old.p != p;
}
