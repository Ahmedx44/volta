import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/page/home_page.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widget/volta_onboarding_illustration.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView();

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final PageController _pageController;

  static const List<_OnboardingContent> _pages = [
    _OnboardingContent(
      title: 'Welcome to Volta',
      description:
          'See exactly how your phone charges and drains, with live numbers that update as it happens.',
    ),
    _OnboardingContent(
      title: 'Everything in one place',
      description:
          'Current, voltage, temperature and charging speed, plus graphs of your battery over the day and week.',
    ),
    _OnboardingContent(
      title: 'Stay in the loop',
      description:
          'Get a nudge when your battery reaches 80%, runs low, or gets too warm. Volta needs permission to send notifications.',
    ),
    _OnboardingContent(
      title: 'Keep recording quietly',
      description:
          'To build your history and health graphs, Volta saves a reading every minute. Allow it to run in the background.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    context.read<OnboardingCubit>().goToPage(page);

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    final cubit = context.read<OnboardingCubit>();

    if (cubit.state.isLastPage) {
      _finishOnboarding();
      return;
    }

    _goToPage(cubit.state.currentPage + 1);
  }

  void _skipOnboarding() {
    _goToPage(OnboardingCubit.totalPages - 1);
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingCompleted', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _requestNotifications() async {
    final cubit = context.read<OnboardingCubit>();

    final status = await cubit.requestNotificationPermission();

    if (!mounted) return;

    if (status.isGranted || status.isProvisional) {
      _nextPage();
      return;
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Notifications are disabled. You can enable them in Settings.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: cubit.openAppSettingsPage,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission was not granted.'),
        ),
      );
    }

    _nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoltaColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            final isLastPage = state.isLastPage;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  _buildHeader(showSkip: !isLastPage),

                  const SizedBox(height: 20),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().goToPage(index);
                      },
                      itemBuilder: (context, index) {
                        return _buildPage(index);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: Color(0xFF2E9E58),
                      dotColor: Color(0xFFD3D3CC),
                      dotHeight: 7,
                      dotWidth: 7,
                      expansionFactor: 3,
                      spacing: 8,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _buildPrimaryButton(
                    label: _getButtonLabel(state.currentPage),
                    onPressed: state.currentPage == 2
                        ? _requestNotifications
                        : state.currentPage == 4
                        ? _finishOnboarding
                        : _nextPage,
                  ),

                  if (state.currentPage == 2 || state.currentPage == 3) ...[
                    const SizedBox(height: 10),
                    _buildSecondaryButton(
                      label: 'Not now',
                      onPressed: _nextPage,
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({required bool showSkip}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: VoltaColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: VoltaColors.softGreen,
            size: 23,
          ),
        ),

        const SizedBox(width: 9),

        const Text(
          'Volta',
          style: TextStyle(
            color: VoltaColors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        const Spacer(),

        if (showSkip)
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: VoltaColors.lightSecondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPage(int index) {
    final page = _pages[index];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VoltaOnboardingIllustration(index: index),

        const SizedBox(height: 32),

        Text(
          page.title,
          style: const TextStyle(
            color: VoltaColors.lightText,
            fontSize: 27,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          page.description,
          style: const TextStyle(
            color: VoltaColors.lightSecondaryText,
            fontSize: 14,
            height: 1.65,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: VoltaColors.primary,
          foregroundColor: VoltaColors.softGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: VoltaColors.lightSecondaryText,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getButtonLabel(int index) {
    switch (index) {
      case 0:
      case 1:
        return 'Continue';
      case 2:
        return 'Allow notifications';
      case 3:
        return 'Get started';
      default:
        return 'Continue';
    }
  }
}

class _OnboardingContent {
  final String title;
  final String description;

  const _OnboardingContent({required this.title, required this.description});
}
