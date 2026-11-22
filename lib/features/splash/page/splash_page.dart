import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:volta/features/home/page/home_page.dart';
import 'package:volta/features/onboarding/page/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkOnboarding();
  }

  Future<void> checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    final completed = prefs.getBool('isOnboardingCompleted') ?? false;

    if (!mounted) return;

    if (completed) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
