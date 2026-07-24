import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/pages/splash_screen.dart';
import '../services/shared_prefs_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'solace_button.dart';

/// TEMPORARY landing screen shown after onboarding/splash until Part D
/// (Auth) and Part E (Home Dashboard) are built. Delete this file and
/// point FindMatchPreviewScreen at the real Login/Home screens once those
/// parts land.
///
/// Includes a "reset onboarding" dev button so anyone testing the app
/// can replay the onboarding flow without reinstalling.
class PlaceholderScreen extends StatelessWidget {
  final String message;

  const PlaceholderScreen({super.key, this.message = 'Next up: Authentication (Part D).'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
              const SizedBox(height: 16),
              Text('You\'re all set!', style: AppTextStyles.headingMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SolaceButton(
                label: 'Reset onboarding (dev)',
                variant: SolaceButtonVariant.outline,
                onPressed: () async {
                  await SharedPrefsService().clearAll();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}