import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

import '../../battery/cubit/battery_cubit.dart';
import '../../battery/cubit/battery_state.dart';
import '../../battery/page/live_stats_page.dart';
import '../../health/page/health_page.dart';
import '../../history/page/history_page.dart';
import '../../settings/page/settings_view.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widet/circle_icon_button.dart';
import '../widet/common.dart';
import '../widet/floating_nav_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  /// Tab titles reflect the real charging state, so "Charging" is never shown
  /// while the phone is on battery.
  static String _title(int tab, bool charging) {
    switch (tab) {
      case 0:
        return charging ? 'Charging' : 'Not charging';
      case 1:
        return charging ? 'Plugged in' : 'Battery';
      case 2:
        return 'Health';
      default:
        return 'History';
    }
  }

  static const _navItems = [
    NavItem(HugeIcons.strokeRoundedBatteryCharging01, 'Charging'),
    NavItem(HugeIcons.strokeRoundedBatteryMedium01, 'Battery'),
    NavItem(HugeIcons.strokeRoundedFavourite, 'Health'),
    NavItem(HugeIcons.strokeRoundedHistory, 'History'),
  ];

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsView()));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.vc;
    final charging = context.select<BatteryCubit, bool>(
      (c) => c.state.snapshot.isCharging,
    );

    // Follow the charger: jump between the Charging and Battery tabs.
    return BlocListener<BatteryCubit, BatteryState>(
      listenWhen: (a, b) => a.snapshot.isCharging != b.snapshot.isCharging,
      listener: (context, state) {
        final home = context.read<HomeCubit>();
        if (home.state.tab < 2) {
          home.selectTab(state.snapshot.isCharging ? 0 : 1);
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: p.page.computeLuminance() > 0.5
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: p.page,
            extendBody: true,
            appBar: AppBar(
              backgroundColor: p.page,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              titleSpacing: 20,
              title: Text(
                _title(state.tab, charging),
                style: vText(
                  28,
                  w: FontWeight.w500,
                  color: p.text,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                CircleIconButton(
                  icon: HugeIcons.strokeRoundedSettings01,
                  label: 'Settings',
                  onTap: () => _openSettings(context),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: VScope(
              child: IndexedStack(
                index: state.tab,
                children: const [
                  LiveStatsPage(charging: true),
                  LiveStatsPage(charging: false),
                  HealthPage(),
                  HistoryPage(),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FloatingNavBar(
                  items: _navItems,
                  index: state.tab,
                  onTap: context.read<HomeCubit>().selectTab,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
