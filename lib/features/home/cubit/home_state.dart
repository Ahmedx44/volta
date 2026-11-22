class HomeState {
  final int tab;
  const HomeState({this.tab = 0});

  HomeState copyWith({int? tab}) => HomeState(tab: tab ?? this.tab);
}
