import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({int initialTab = 0}) : super(HomeState(tab: initialTab));

  static const tabCount = 4;

  void selectTab(int tab) {
    if (tab < 0 || tab >= tabCount || tab == state.tab) return;
    emit(state.copyWith(tab: tab));
  }
}
