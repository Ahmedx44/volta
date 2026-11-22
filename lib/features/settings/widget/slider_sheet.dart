import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../home/widet/common.dart';
import 'app_sheet.dart';

/// Bottom sheet with a big value readout and a slider. Returns the chosen
/// value when saved, null if dismissed.
Future<int?> showSliderSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required int value,
  required int min,
  required int max,
  required int step,
  String unit = '',
}) {
  return showAppSheet<int>(
    context,
    title: title,
    subtitle: subtitle,
    builder: (sheetContext) =>
        _SliderBody(value: value, min: min, max: max, step: step, unit: unit),
  );
}

class _SliderBody extends StatefulWidget {
  final int value, min, max, step;
  final String unit;
  const _SliderBody({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.unit,
  });

  @override
  State<_SliderBody> createState() => _SliderBodyState();
}

class _SliderBodyState extends State<_SliderBody> {
  late double _value = widget.value.toDouble();

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Column(
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${_value.round()}', style: vText(56, w: FontWeight.w300)),
              const SizedBox(width: 4),
              Text(widget.unit, style: vText(22, color: p.textSecondary)),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: p.green,
            inactiveTrackColor: p.accentSoft,
            thumbColor: p.accent,
            overlayColor: p.green.withValues(alpha: 0.2),
            trackHeight: 8,
          ),
          child: Slider(
            value: _value,
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: (widget.max - widget.min) ~/ widget.step,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.min}${widget.unit}',
                style: vText(12, color: p.textFaint),
              ),
              Text(
                '${widget.max}${widget.unit}',
                style: vText(12, color: p.textFaint),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SheetButton(
          label: 'Save',
          onTap: () => Navigator.of(context).pop(_value.round()),
        ),
      ],
    );
  }
}
