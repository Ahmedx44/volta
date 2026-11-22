class HistoryState {
  final int rangeIndex;
  const HistoryState({this.rangeIndex = 0});

  HistoryState copyWith({int? rangeIndex}) =>
      HistoryState(rangeIndex: rangeIndex ?? this.rangeIndex);

  Duration get range => HistoryRange.values[rangeIndex].span;
}

enum HistoryRange {
  day('24 hours', Duration(hours: 24)),
  week('7 days', Duration(days: 7)),
  month('30 days', Duration(days: 30));

  final String label;
  final Duration span;
  const HistoryRange(this.label, this.span);
}
