import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/widgets/auth_gate.dart';
import '../cubit/onboarding_cubit.dart';
import 'welcome_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    // Keep the logo on screen briefly even if the pref lookup resolves
    // instantly, so the splash doesn't flash by unnoticed.
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 1400)),
      context.read<OnboardingCubit>().hasCompletedOnboarding(),
    ]);

    if (!mounted) return;

    final hasCompletedOnboarding = results[1] as bool;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            hasCompletedOnboarding ? const AuthGate() : const WelcomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.spa_rounded,
                    color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 20),
              Text('Solace',
                  style:
                      AppTextStyles.displayLarge.copyWith(color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                'A private space to feel better.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Colors.white.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
