import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:volta/features/settings/cubit/settings_cubit.dart';
import 'package:volta/features/settings/cubit/settings_state.dart';
import 'package:volta/features/splash/page/splash_page.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => SettingsCubit()..load(),
      child: BlocSelector<SettingsCubit, SettingsState, AppThemeMode>(
        selector: (state) => state.themeMode,
        builder: (context, mode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: switch (mode) {
            AppThemeMode.system => ThemeMode.system,
            AppThemeMode.light => ThemeMode.light,
            AppThemeMode.dark => ThemeMode.dark,
          },
          home: const SplashPage(),
        ),
      ),
    ),
  );
}
