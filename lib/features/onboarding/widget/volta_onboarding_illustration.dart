import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays one of Volta's four onboarding illustrations.
///
/// Index:
/// 0 = battery filling
/// 1 = live battery statistics
/// 2 = battery alerts
/// 3 = background recording
class VoltaOnboardingIllustration extends StatelessWidget {
  const VoltaOnboardingIllustration({
    super.key,
    required this.index,
    this.height = 290,
  }) : assert(index >= 0 && index < 4);

  final int index;
  final double height;

  static const _assets = <String>[
    'assets/onboarding/battery_filling.svg',
    'assets/onboarding/live_stats.svg',
    'assets/onboarding/battery_alerts.svg',
    'assets/onboarding/background_recording.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF7E5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: SvgPicture.asset(
        _assets[index],
        fit: BoxFit.contain,
        semanticsLabel: const [
          'Battery filling up',
          'Live battery statistics',
          'Battery notification alerts',
          'Background battery recording',
        ][index],
      ),
    );
  }
}
