import 'package:flutter_bloc/flutter_bloc.dart';

import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryState());

  void selectRange(int index) {
    if (index < 0 || index >= HistoryRange.values.length) return;
    emit(state.copyWith(rangeIndex: index));
  }
}
