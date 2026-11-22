import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'common.dart';

/// Battery level card: the card fills with an animated green wave.
class WaveLevelCard extends StatefulWidget {
  final int percent;
  final int chargeMah;
  final int designMah;

  const WaveLevelCard({
    super.key,
    required this.percent,
    required this.chargeMah,
    required this.designMah,
  });

  @override
  State<WaveLevelCard> createState() => _WaveLevelCardState();
}

class _WaveLevelCardState extends State<WaveLevelCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    final target = (widget.percent / 100).clamp(0.0, 1.0) * 0.96;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: p.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, fill, _) => AnimatedBuilder(
          animation: _wave,
          builder: (context, _) {
            final phase = _wave.value;
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WavePainter(fill, phase, p.green),
                  ),
                ),
                // Text in normal colors on the card background...
                _Labels(
                  percent: widget.percent,
                  chargeMah: widget.chargeMah,
                  designMah: widget.designMah,
                  main: p.text,
                  soft: p.textSecondary,
                ),
                // ...and the same text in dark green, shown only where the
                // wave covers it, so it stays readable in light and dark mode.
                Positioned.fill(
                  child: ClipPath(
                    clipper: _WaveClipper(fill, phase),
                    child: _Labels(
                      percent: widget.percent,
                      chargeMah: widget.chargeMah,
                      designMah: widget.designMah,
                      main: p.onGreen,
                      soft: p.onGreen,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Labels extends StatelessWidget {
  final int percent;
  final int chargeMah;
  final int designMah;
  final Color main;
  final Color soft;
  const _Labels({
    required this.percent,
    required this.chargeMah,
    required this.designMah,
    required this.main,
    required this.soft,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Battery level', style: vText(13, color: soft)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$percent',
                style: vText(46, w: FontWeight.w300, color: main),
              ),
              Text('%', style: vText(20, color: soft)),
            ],
          ),
          const SizedBox(height: 2),
          Text('$chargeMah / $designMah mAh', style: vText(11.5, color: soft)),
        ],
      ),
    );
  }
}

Path _wavePath(Size size, double fill, double phase, double amp, double shift) {
  final top = size.height * (1 - fill);
  final path = Path()..moveTo(0, size.height);
  for (var x = 0.0; x <= size.width; x += 2) {
    final y =
        top +
        math.sin(
              (x / size.width * 2 * math.pi) + (phase + shift) * 2 * math.pi,
            ) *
            amp;
    path.lineTo(x, y);
  }
  return path
    ..lineTo(size.width, size.height)
    ..close();
}

class _WaveClipper extends CustomClipper<Path> {
  final double fill;
  final double phase;
  const _WaveClipper(this.fill, this.phase);

  @override
  Path getClip(Size size) =>
      fill <= 0 ? Path() : _wavePath(size, fill, phase, 5, 0.5);

  @override
  bool shouldReclip(covariant _WaveClipper old) =>
      old.fill != fill || old.phase != phase;
}

class _WavePainter extends CustomPainter {
  final double fill; // 0..1 of the height
  final double phase; // 0..1
  final Color color;
  const _WavePainter(this.fill, this.phase, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (fill <= 0) return;
    canvas.drawPath(
      _wavePath(size, fill, phase, 7, 0),
      Paint()..color = color.withValues(alpha: 0.45),
    );
    canvas.drawPath(
      _wavePath(size, fill, phase, 5, 0.5),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.fill != fill || old.phase != phase || old.color != color;
}
