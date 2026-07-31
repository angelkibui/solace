import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/concern_list_tile.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/solace_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import 'find_match_preview_screen.dart';


class ConcernSelectionScreen extends StatelessWidget {
  const ConcernSelectionScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What\'s on your mind today?',
                      style: AppTextStyles.headingLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Select all that apply. This helps us tailor your experience and '
                    'find the most supportive tools for your journey.',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: AppConstants.concerns.length,
                    itemBuilder: (context, index) {
                      final concern = AppConstants.concerns[index];
                      return ConcernListTile(
                        concern: concern,
                        tintIndex: index,
                        isSelected:
                            state.selectedConcerns.contains(concern.title),
                        onTap: () => context
                            .read<OnboardingCubit>()
                            .toggleConcern(concern.title),
                      );
                    },
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
                  label: 'Continue',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const FindMatchPreviewScreen()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
