import 'package:material_ui/material_ui.dart';

/// Colors for the main app screens, one set per brightness.
/// Read with `context.vc`.
class VPalette extends ThemeExtension<VPalette> {
  final Color page;
  final Color card;
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color textFaint;

  /// Solid green used for highlighted cards and the selected nav tab.
  final Color green;
  final Color onGreen;

  /// Green for lines, toggles and small accents.
  final Color accent;
  final Color accentSoft;

  final Color circle;
  final Color onCircle;
  final Color track;
  final Color navBg;
  final Color navIcon;
  final Color shadow;

  const VPalette({
    required this.page,
    required this.card,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textFaint,
    required this.green,
    required this.onGreen,
    required this.accent,
    required this.accentSoft,
    required this.circle,
    required this.onCircle,
    required this.track,
    required this.navBg,
    required this.navIcon,
    required this.shadow,
  });

  static const light = VPalette(
    page: Color(0xFFF5F5F3),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFECECE8),
    text: Color(0xFF1F2A24),
    textSecondary: Color(0xFF5E5E5A),
    textFaint: Color(0xFF8A8A84),
    green: Color(0xFF64D585),
    onGreen: Color(0xFF1F3D2A),
    accent: Color(0xFF2E9E58),
    accentSoft: Color(0xFFE6F8EC),
    circle: Color(0xFFB9EFC8),
    onCircle: Color(0xFF1F3D2A),
    track: Color(0xFFD3D3CC),
    navBg: Color(0xFFFFFFFF),
    navIcon: Color(0xFF3D3D3A),
    shadow: Color(0x14000000),
  );

  static const dark = VPalette(
    page: Color(0xFF0D1110),
    card: Color(0xFF171D1A),
    border: Color(0xFF252D29),
    text: Color(0xFFEEF3F0),
    textSecondary: Color(0xFFA3AFA8),
    textFaint: Color(0xFF6F7B75),
    green: Color(0xFF64D585),
    onGreen: Color(0xFF0F2619),
    accent: Color(0xFF5FD98A),
    accentSoft: Color(0xFF1E2B24),
    circle: Color(0xFF24372C),
    onCircle: Color(0xFFB9EFC8),
    track: Color(0xFF2E3833),
    navBg: Color(0xFF1B221F),
    navIcon: Color(0xFFA3AFA8),
    shadow: Color(0x66000000),
  );

  @override
  VPalette copyWith() => this;

  @override
  VPalette lerp(ThemeExtension<VPalette>? other, double t) =>
      other is VPalette && t >= 0.5 ? other : this;
}

extension VPaletteContext on BuildContext {
  VPalette get vc =>
      Theme.of(this).extension<VPalette>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? VPalette.dark
          : VPalette.light);
}
