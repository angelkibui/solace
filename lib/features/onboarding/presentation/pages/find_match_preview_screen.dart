import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../../core/widgets/therapist_card.dart';
import '../../../auth/presentation/widgets/auth_gate.dart';
import '../cubit/onboarding_cubit.dart';


class FindMatchPreviewScreen extends StatefulWidget {
  const FindMatchPreviewScreen({super.key});

  @override
  State<FindMatchPreviewScreen> createState() => _FindMatchPreviewScreenState();
}

class _FindMatchPreviewScreenState extends State<FindMatchPreviewScreen> {
  static const _filters = [
    'All Specialties',
    'Kinyarwanda',
    'English',
    'Price Range'
  ];
  int _activeFilter = 0;

  static const _previewTherapists = [
    (
      name: 'Dr. Aline Mutoni',
      role: 'Clinical Psychologist',
      traits: ['Trauma Informed', 'CBT Specialist'],
      bio:
          'Specializing in post-traumatic growth and family dynamics with over 10 years '
          'of experience in Kigali.',
      languages: ['Kinyarwanda', 'English'],
      rate: '35,000 RWF / hr',
    ),
    (
      name: 'Jean-Luc Nshimiye',
      role: 'Licensed Counselor',
      traits: ['Anxiety', 'Grief Support'],
      bio:
          'Dedicated to providing a safe, non-judgmental space for individuals '
          'navigating life\'s transitions and workplace stress.',
      languages: ['English', 'French'],
      rate: '28,000 RWF / hr',
    ),
  ];

  Future<void> _handleContinue() async {
    await context.read<OnboardingCubit>().completeOnboarding();
    if (!mounted) return;
    // Straight to Register (not AuthGate/Login) — someone finishing
    // onboarding for the first time is creating an account, not returning
    // to one. AuthGate is for app relaunches (see SplashScreen), where
    // AuthBloc's cached session is what should decide the destination.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate(startAtRegister: true)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Search arrives with the Therapist Directory (Part F).')),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Licensed Professionals',
                      style: AppTextStyles.headingLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Find vetted Rwandan therapists specializing in trauma, anxiety, and '
                    'family counseling. Filter by language and expertise.',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isActive = _activeFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _activeFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.navy : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                isActive ? AppColors.navy : AppColors.divider),
                      ),
                      child: Text(
                        _filters[index],
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              isActive ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                itemCount: _previewTherapists.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final t = _previewTherapists[index];
                  return TherapistCard(
                    name: t.name,
                    roleLabel: t.role,
                    traits: t.traits,
                    bio: t.bio,
                    languages: t.languages,
                    rate: t.rate,
                    onBook: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Booking opens with Part G (Appointment Booking).')),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                top: false,
                child: SolaceButton(
                    label: 'Get Started', onPressed: _handleContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
