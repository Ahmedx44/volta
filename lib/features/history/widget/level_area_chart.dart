import 'package:flutter/widgets.dart';

import '../../../core/service/history_store.dart';
import '../../home/widet/common.dart';

class LevelAreaChart extends StatelessWidget {
  final List<LevelSample> samples;
  final Duration span;
  const LevelAreaChart({super.key, required this.samples, required this.span});

  @override
  Widget build(BuildContext context) {
    if (samples.length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Text(
            'Collecting data. Keep the app installed and check back soon.',
            textAlign: TextAlign.center,
            style: vText(12, color: context.vc.textSecondary),
          ),
        ),
      );
    }
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: CustomPaint(painter: _AreaPainter(samples, span, context.vc)),
    );
  }
}

class _AreaPainter extends CustomPainter {
  final List<LevelSample> samples;
  final Duration span;
  final VPalette p;
  const _AreaPainter(this.samples, this.span, this.p);

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0;
    const top = 6.0;
    final bottom = size.height - 20;
    final width = size.width - left - 4;
    final height = bottom - top;

    final grid = Paint()
      ..color = p.border
      ..strokeWidth = 0.75;
    for (final v in [0, 50, 100]) {
      final y = bottom - height * v / 100;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), grid);
      _text(canvas, '$v', Offset(left - 6, y - 7), p.textFaint, right: true);
    }

    final start = DateTime.now().subtract(span);
    final points = [
      for (final s in samples)
        Offset(
          left +
              width *
                  (s.time.difference(start).inSeconds / span.inSeconds).clamp(
                    0.0,
                    1.0,
                  ),
          bottom - height * s.percent / 100,
        ),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    final area = Path.from(line)
      ..lineTo(points.last.dx, bottom)
      ..lineTo(points.first.dx, bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.green.withValues(alpha: 0.45),
            p.green.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTRB(left, top, size.width, bottom)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = p.accent,
    );

    final inHours = span.inHours <= 24;
    final total = inHours ? span.inHours : span.inDays;
    final unit = inHours ? 'h' : 'd';
    final labelY = size.height - 14;
    _text(canvas, '-$total$unit', Offset(left, labelY), p.textFaint);
    _text(
      canvas,
      '-${total ~/ 2}$unit',
      Offset(left + width / 2 - 10, labelY),
      p.textFaint,
    );
    _text(canvas, 'now', Offset(size.width - 22, labelY), p.textFaint);
  }

  void _text(Canvas c, String t, Offset o, Color color, {bool right = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: vText(11, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, right ? o - Offset(tp.width, 0) : o);
  }

  @override
  bool shouldRepaint(covariant _AreaPainter old) => true;
}
