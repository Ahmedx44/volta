import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_palette.dart';
import '../../home/widet/circle_icon_button.dart';
import '../../home/widet/common.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widget/widget.dart';


/// Each value row opens a bottom sheet to change it.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const _cardPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.page.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: p.page,
        appBar: AppBar(
          backgroundColor: p.page,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              CircleIconButton(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                label: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: vText(
                  28,
                  w: FontWeight.w500,
                  color: p.text,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        body: VScope(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              final cubit = context.read<SettingsCubit>();
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  const SectionHeader('Alerts'),
                  VCard(
                    padding: _cardPadding,
                    child: Column(
                      children: [
                        SettingsSwitchRow(
                          icon: HugeIcons.strokeRoundedNotification01,
                          title: 'Charge limit alert',
                          value: state.chargeLimitAlert,
                          onToggle: () =>
                              _guard(context, cubit.toggleChargeLimitAlert()),
                        ),
                        SettingsValueRow(
                          icon: HugeIcons.strokeRoundedPercent,
                          title: 'Alert at',
                          value: '${state.alertAt}%',
                          onTap: () => _pickAlertAt(context, state),
                        ),
                        SettingsSwitchRow(
                          icon: HugeIcons.strokeRoundedBatteryLow,
                          title: 'Low battery alert',
                          value: state.lowBatteryAlert,
                          onToggle: () =>
                              _guard(context, cubit.toggleLowBatteryAlert()),
                        ),
                        SettingsSwitchRow(
                          icon: HugeIcons.strokeRoundedFire,
                          title: 'Overheat warning',
                          value: state.overheatWarning,
                          onToggle: () =>
                              _guard(context, cubit.toggleOverheatWarning()),
                          last: true,
                        ),
                      ],
                    ),
                  ),
                  const SectionHeader('Recording'),
                  VCard(
                    padding: _cardPadding,
                    child: Column(
                      children: [
                        SettingsValueRow(
                          icon: HugeIcons.strokeRoundedClock01,
                          title: 'Sample every',
                          value: '${state.sampleEveryMinutes} min',
                          onTap: () => _pickSample(context, state),
                        ),
                        SettingsValueRow(
                          icon: HugeIcons.strokeRoundedDatabase,
                          title: 'Keep history for',
                          value: '${state.keepHistoryDays} days',
                          onTap: () => _pickKeep(context, state),
                        ),
                        SettingsSwitchRow(
                          icon: HugeIcons.strokeRoundedPlayCircle,
                          title: 'Run in background',
                          value: state.runInBackground,
                          onToggle: () =>
                              _guard(context, cubit.toggleRunInBackground()),
                          last: true,
                        ),
                      ],
                    ),
                  ),
                  const SectionHeader('Display'),
                  VCard(
                    padding: _cardPadding,
                    child: Column(
                      children: [
                        SettingsValueRow(
                          icon: HugeIcons.strokeRoundedThermometer,
                          title: 'Temperature unit',
                          value: state.useFahrenheit ? 'Fahrenheit' : 'Celsius',
                          onTap: () => _pickUnit(context, state),
                        ),
                        SettingsValueRow(
                          icon: HugeIcons.strokeRoundedBatteryFull,
                          title: 'Design capacity',
                          value: '${state.designCapacityMah} mAh',
                          onTap: () => _pickCapacity(context, state),
                        ),
                        SettingsValueRow(
                          icon: HugeIcons.strokeRoundedPaintBoard,
                          title: 'Theme',
                          value: state.themeMode.label,
                          onTap: () => _pickTheme(context, state),
                          last: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Runs a toggle that may need a permission; explains if it was refused.
  Future<void> _guard(BuildContext context, Future<bool> toggle) async {
    final ok = await toggle;
    if (!ok && context.mounted) await showPermissionSheet(context);
  }

  Future<void> _pickAlertAt(BuildContext context, SettingsState s) async {
    final cubit = context.read<SettingsCubit>();
    final v = await showSliderSheet(
      context,
      title: 'Charge limit alert',
      subtitle: 'Notify me when the battery reaches this level while charging.',
      value: s.alertAt,
      min: 50,
      max: 100,
      step: 5,
      unit: '%',
    );
    if (v != null) cubit.setAlertAt(v);
  }

  Future<void> _pickSample(BuildContext context, SettingsState s) async {
    final cubit = context.read<SettingsCubit>();
    final v = await showOptionSheet<int>(
      context,
      title: 'Sample every',
      subtitle: 'How often a battery reading is saved to history.',
      selected: s.sampleEveryMinutes,
      options: [
        for (final m in SettingsCubit.sampleOptions)
          SheetOption(
            m,
            m == 1 ? '1 minute' : '$m minutes',
            description: m == 1 ? 'Most detailed' : null,
          ),
      ],
    );
    if (v != null) cubit.setSampleInterval(v);
  }

  Future<void> _pickKeep(BuildContext context, SettingsState s) async {
    final cubit = context.read<SettingsCubit>();
    final v = await showOptionSheet<int>(
      context,
      title: 'Keep history for',
      subtitle: 'Older readings are deleted automatically.',
      selected: s.keepHistoryDays,
      options: [
        for (final d in SettingsCubit.keepOptions)
          SheetOption(d, d == 365 ? '1 year' : '$d days'),
      ],
    );
    if (v != null) cubit.setKeepHistory(v);
  }

  Future<void> _pickUnit(BuildContext context, SettingsState s) async {
    final cubit = context.read<SettingsCubit>();
    final v = await showOptionSheet<bool>(
      context,
      title: 'Temperature unit',
      selected: s.useFahrenheit,
      options: const [
        SheetOption(false, 'Celsius', description: '°C'),
        SheetOption(true, 'Fahrenheit', description: '°F'),
      ],
    );
    if (v != null) cubit.setFahrenheit(v);
  }

  Future<void> _pickCapacity(BuildContext context, SettingsState s) async {
    final cubit = context.read<SettingsCubit>();
    final v = await showCapacitySheet(context, s.designCapacityMah);
    if (v != null) cubit.setDesignCapacity(v);
  }

  Future<void> _pickTheme(BuildContext context, SettingsState s) async {
    final cubit = context.read<SettingsCubit>();
    final v = await showOptionSheet<AppThemeMode>(
      context,
      title: 'Theme',
      selected: s.themeMode,
      options: const [
        SheetOption(
          AppThemeMode.system,
          'System',
          description: 'Match your phone setting',
        ),
        SheetOption(AppThemeMode.light, 'Light'),
        SheetOption(AppThemeMode.dark, 'Dark'),
      ],
    );
    if (v != null) cubit.setThemeMode(v);
  }
}
