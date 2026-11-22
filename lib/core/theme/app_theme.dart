import 'package:material_ui/material_ui.dart';

import 'app_palette.dart';

class VoltaColors {
  VoltaColors._();

  // Brand
  static const primary = Color(0xFF16A34A);
  static const primaryDark = Color(0xFF15803D);
  static const secondaryGreen = Color(0xFF22C55E);
  static const softGreen = Color(0xFFDCFCE7);
  static const darkGreen = Color(0xFF26352A);

  // Light theme
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF7F7F7);
  static const lightText = Color(0xFF171717);
  static const lightSecondaryText = Color(0xFF737373);
  static const lightBorder = Color(0xFFE5E5E5);

  // Dark theme
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF111111);
  static const darkCard = Color(0xFF1A1A1A);
  static const darkText = Color(0xFFFFFFFF);
  static const darkSecondaryText = Color(0xFFA3A3A3);
  static const darkBorder = Color(0xFF292929);

  // Status
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [VPalette.light],
      scaffoldBackgroundColor: VoltaColors.lightBackground,

      colorScheme: const ColorScheme.light(
        primary: VoltaColors.primary,
        onPrimary: Colors.white,
        secondary: Color(0xFFB9EFC8),
        onSecondary: Colors.black,
        surface: VoltaColors.lightSurface,
        onSurface: VoltaColors.lightText,
        error: VoltaColors.error,
        onError: Colors.white,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [VPalette.dark],
      scaffoldBackgroundColor: VoltaColors.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4ADE80),
        onPrimary: Colors.black,
        secondary: Color(0xFFB9EFC8),
        onSecondary: Colors.white,
        surface: VoltaColors.darkSurface,
        onSurface: VoltaColors.darkText,
        error: Color(0xFFF87171),
        onError: Color(0xFF450A0A),
      ),
    );
  }
}
