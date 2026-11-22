import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../battery/cubit/battery_cubit.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../cubit/home_cubit.dart';
import 'home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (c) => BatteryCubit(c.read<SettingsCubit>())),
        BlocProvider(
          create: (c) {
            final charging = c.read<BatteryCubit>().state.snapshot.isCharging;
            return HomeCubit(initialTab: charging ? 0 : 1);
          },
        ),
      ],
      child: const HomeView(),
    );
  }
}
