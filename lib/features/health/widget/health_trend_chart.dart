import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../home/widet/common.dart';

/// Monthly health line. [months] are 'yyyy-MM' keys, oldest first.
class HealthTrendChart extends StatelessWidget {
  final Map<String, int> healthByMonth;
  const HealthTrendChart({super.key, required this.healthByMonth});

  @override
  Widget build(BuildContext context) {
    final keys = healthByMonth.keys.toList()..sort();
    final shown = keys.length > 6 ? keys.sublist(keys.length - 6) : keys;

    if (shown.length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'Not enough data yet. The app logs one health reading per month.',
          style: vText(12, color: context.vc.textSecondary),
        ),
      );
    }
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          context.vc,
          [for (final k in shown) int.parse(k.substring(5))],
          [for (final k in shown) healthByMonth[k]!],
        ),
      ),
    );
  }
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class _TrendPainter extends CustomPainter {
  final VPalette p;
  final List<int> months;
  final List<int> values;
  const _TrendPainter(this.p, this.months, this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final lo = values.reduce(math.min) - 2;
    final hi = values.reduce(math.max) + 2;
    final width = size.width - 40;
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(
          20 + width * i / (values.length - 1),
          14 + (size.height - 46) * (1 - (values[i] - lo) / (hi - lo)),
        ),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round
        ..color = p.accent,
    );

    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        8,
        Paint()..color = p.green.withValues(alpha: 0.3),
      );
      canvas.drawCircle(points[i], 4, Paint()..color = p.accent);
      _label(canvas, '${values[i]}', points[i] + const Offset(0, -20), p.text);
      _label(
        canvas,
        _monthNames[months[i] - 1],
        Offset(points[i].dx, size.height - 14),
        p.textFaint,
      );
    }
  }

  void _label(Canvas canvas, String text, Offset center, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: vText(11, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.values != values || old.months != months || old.p != p;
}
