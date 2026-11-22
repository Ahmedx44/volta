import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  static const int totalPages = 4;

  void goToPage(int page) {
    if (page < 0 || page >= totalPages) return;

    emit(state.copyWith(currentPage: page));
  }

  void nextPage() {
    if (state.isLastPage) return;

    emit(state.copyWith(currentPage: state.currentPage + 1));
  }

  void previousPage() {
    if (state.isFirstPage) return;

    emit(state.copyWith(currentPage: state.currentPage - 1));
  }

  void skip() {
    emit(state.copyWith(currentPage: totalPages - 1));
  }

  Future<PermissionStatus> requestNotificationPermission() async {
    return Permission.notification.request();
  }

  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted || status.isProvisional;
  }

  Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }

  void reset() {
    emit(const OnboardingState());
  }
}
