import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';

export '../../../core/theme/app_palette.dart' show VPalette, VPaletteContext;

/// Text style used across the app. A null [color] inherits the screen's
/// default (set from the palette), so it follows light/dark mode.
TextStyle vText(
  double size, {
  FontWeight w = FontWeight.w400,
  Color? color,
  double? letterSpacing,
}) => GoogleFonts.lexendDeca(
  fontSize: size,
  fontWeight: w,
  color: color,
  letterSpacing: letterSpacing,
);

/// Gives a screen body the palette's text color.
class VScope extends StatelessWidget {
  final Widget child;
  const VScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: TextStyle(color: context.vc.text),
    child: child,
  );
}

class VCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool green;

  const VCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.green = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: green ? p.green : p.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: green ? p.green : p.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionHeader(this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 28, 6, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: vText(18, w: FontWeight.w500)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, style: vText(12, color: p.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final bool green;
  const StatCard(
    this.label,
    this.value,
    this.sub, {
    super.key,
    this.green = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    final main = green ? p.onGreen : p.text;
    final soft = green ? p.onGreen : p.textSecondary;
    return VCard(
      green: green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: vText(13, color: soft)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: vText(22, w: FontWeight.w500, color: main),
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: vText(11, color: green ? p.onGreen : p.textFaint)),
        ],
      ),
    );
  }
}

/// Two-column grid of equal-height rows.
class TwoColumn extends StatelessWidget {
  final List<Widget> children;
  const TwoColumn(this.children, {super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 12));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

String fmtDuration(Duration d) {
  final m = d.inMinutes;
  if (m < 60) return '$m min';
  return '${m ~/ 60}h ${m % 60}m';
}

String signed(num v, {int digits = 1}) =>
    '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(digits)}';
