class OnboardingState {
  final int currentPage;

  const OnboardingState({this.currentPage = 0});

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(currentPage: currentPage ?? this.currentPage);
  }

  bool get isFirstPage => currentPage == 0;

  bool get isLastPage => currentPage == 3;
}
