import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../home/widet/common.dart';
import 'app_sheet.dart';

/// Bottom sheet to type the phone's design capacity, with quick presets.
Future<int?> showCapacitySheet(BuildContext context, int current) {
  return showAppSheet<int>(
    context,
    title: 'Design capacity',
    subtitle: 'The capacity printed on your battery or in the phone specs.',
    builder: (_) => _CapacityBody(current: current),
  );
}

class _CapacityBody extends StatefulWidget {
  final int current;
  const _CapacityBody({required this.current});

  @override
  State<_CapacityBody> createState() => _CapacityBodyState();
}

class _CapacityBodyState extends State<_CapacityBody> {
  static const _presets = [3000, 4000, 4500, 5000, 6000];
  late final _controller = TextEditingController(text: '${widget.current}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _value => int.tryParse(_controller.text);
  bool get _valid => _value != null && _value! >= 500 && _value! <= 20000;

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: p.page,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.border, width: 0.8),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: vText(32, w: FontWeight.w300, color: p.text),
            cursorColor: p.accent,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              suffixText: 'mAh',
              suffixStyle: vText(16, color: p.textSecondary),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in _presets)
              GestureDetector(
                onTap: () => setState(() => _controller.text = '$v'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _value == v ? p.green : p.accentSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$v',
                    style: vText(13, color: _value == v ? p.onGreen : p.accent),
                  ),
                ),
              ),
          ],
        ),
        if (_controller.text.isNotEmpty && !_valid) ...[
          const SizedBox(height: 10),
          Text(
            'Enter a value between 500 and 20000 mAh.',
            style: vText(12, color: const Color(0xFFE05555)),
          ),
        ],
        const SizedBox(height: 22),
        Opacity(
          opacity: _valid ? 1 : 0.4,
          child: SheetButton(
            label: 'Save',
            onTap: () {
              if (_valid) Navigator.of(context).pop(_value);
            },
          ),
        ),
      ],
    );
  }
}
