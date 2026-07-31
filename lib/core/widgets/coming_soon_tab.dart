import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'custom_app_bar.dart';

/// TEMPORARY body for a bottom-nav tab whose feature hasn't been built
/// yet (Therapists = Part F, Circles = Part I, Chat = Part J, Profile =
/// Part M). Unlike PlaceholderScreen (used for the pre-Home "you're all
/// set" moment), this is meant to live *inside* MainShell's IndexedStack
/// as a tab body — no back button, no dev reset action, just an honest
/// "not built yet" per tab. Delete each usage as its real feature lands.
class ComingSoonTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final String partLabel;

  const ComingSoonTab(
      {super.key,
      required this.title,
      required this.icon,
      required this.partLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title, showBackButton: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text('$title is on its way',
                  style: AppTextStyles.headingSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'This tab arrives with $partLabel.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
