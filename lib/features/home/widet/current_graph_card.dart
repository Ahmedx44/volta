import 'package:flutter/widgets.dart';

import 'common.dart';

class CurrentGraphCard extends StatelessWidget {
  final List<double> values;
  final String title;
  final String latest;

  const CurrentGraphCard({
    super.key,
    required this.values,
    required this.title,
    required this.latest,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return VCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: vText(13, color: p.textSecondary)),
                  const SizedBox(height: 4),
                  Text(latest, style: vText(26, w: FontWeight.w500)),
                ],
              ),
              Text(
                'Last ${values.length * 3} s',
                style: vText(12, color: p.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(painter: _LinePainter(values, p)),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final VPalette p;
  const _LinePainter(this.values, this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = p.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.length < 2) return;

    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    if (hi - lo < 1) hi = lo + 1;

    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(
          size.width * i / (values.length - 1),
          size.height - 8 - (values[i] - lo) / (hi - lo) * (size.height - 16),
        ),
    ];

    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final mid = (pts[i - 1].dx + pts[i].dx) / 2;
      line.cubicTo(mid, pts[i - 1].dy, mid, pts[i].dy, pts[i].dx, pts[i].dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
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
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = p.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      pts.last,
      8,
      Paint()..color = p.green.withValues(alpha: 0.35),
    );
    canvas.drawCircle(pts.last, 4.5, Paint()..color = p.accent);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => true;
}
