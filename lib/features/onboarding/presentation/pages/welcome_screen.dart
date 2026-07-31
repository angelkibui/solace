import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../auth/presentation/widgets/auth_gate.dart';
import '../cubit/onboarding_cubit.dart';
import 'concern_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const _adjectives = [
    'Quiet',
    'Gentle',
    'Calm',
    'Brave',
    'Wise',
    'Kind',
    'Steady',
    'Bright',
    'Warm',
    'Bold',
  ];
  static const _nouns = [
    'Forest',
    'River',
    'Mountain',
    'Ocean',
    'Sky',
    'Meadow',
    'Harbor',
    'Willow',
    'Ember',
    'Dawn',
  ];

  final _random = Random();
  late String _alias;
  int _selectedPresenceIndex = 0;

  @override
  void initState() {
    super.initState();
    _alias = _generateAlias();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OnboardingCubit>().setAlias(_alias);
    });
  }

  String _generateAlias() {
    final adjective = _adjectives[_random.nextInt(_adjectives.length)];
    final noun = _nouns[_random.nextInt(_nouns.length)];
    final number = _random.nextInt(90000) +
        10000; // 5-digit suffix, matches Figma's "BornASaint69767" style
    return '$adjective$noun$number';
  }

  void _shuffleAlias() {
    setState(() => _alias = _generateAlias());
    context.read<OnboardingCubit>().setAlias(_alias);
  }

  void _handleGetStarted() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ConcernSelectionScreen()),
    );
  }

  /// Onboarding (alias, concerns, find-match preview) is only meant for
  /// someone setting up Solace for the first time — forcing a returning
  /// user, or anyone reinstalling/testing, through all three screens
  /// before they can even reach Login was a genuine gap. This skips
  /// straight to AuthGate's Login branch instead, same as SplashScreen
  /// does for a device that's already completed onboarding.
  void _handleAlreadyHaveAccount() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.info.withValues(alpha: 0.9),
                        AppColors.primary.withValues(alpha: 0.9)
                      ],
                    ),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              Text('Welcome to\nSolace',
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(AppConstants.appTagline,
                  style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 28),

              // Privacy First card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.shield_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Privacy First',
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 3),
                          Text(
                            'Get help without fear, judgment, or anyone else knowing. '
                            'Your presence is entirely confidential.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Alias
              Text('Your Anonymous Alias', style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _alias,
                        style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    InkWell(
                      onTap: _shuffleAlias,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.refresh_rounded,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap refresh to find an identity that resonates with you.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Presence color
              Text('Select Your Presence', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    List.generate(AppConstants.presenceColors.length, (index) {
                  final color = AppConstants.presenceColors[index];
                  final isSelected = _selectedPresenceIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPresenceIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: isSelected ? 52 : 44,
                      height: isSelected ? 52 : 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected ? AppColors.navy : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              SolaceButton(
                label: 'Get Started',
                variant: SolaceButtonVariant
                    .secondary, // navy hero CTA, matches Figma
                icon: Icons.arrow_forward_rounded,
                onPressed: _handleGetStarted,
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: _handleAlreadyHaveAccount,
                  child: Text.rich(
                    TextSpan(
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log in',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              Text.rich(
                TextSpan(
                  style: AppTextStyles.caption,
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Safety Guidelines',
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: AppColors.textPrimary),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Safety Guidelines page coming soon.')),
                                ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
