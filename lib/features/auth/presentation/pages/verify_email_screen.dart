import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/solace_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// D5 — shown right after registration. Lets the user re-check their
/// verification status on demand (no background polling, to keep this
/// cheap on Firebase Auth calls) and resend the link if it didn't arrive.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _resent = false;

  Future<void> _checkStatus() async {
    setState(() => _checking = true);
    context.read<AuthBloc>().add(const EmailVerificationCheckRequested());
    // Give the Bloc a beat to reload the Firebase user and re-emit.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _checking = false);

    final state = context.read<AuthBloc>().state;
    final isVerified = state is AuthAuthenticated && state.emailVerified;
    if (!isVerified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not verified yet — check your inbox and try again.")),
      );
    }
    // If verified, AuthGate rebuilds automatically off the new AuthBloc
    // state and moves past this screen — no manual navigation needed here.
  }

  void _resend() {
    context.read<AuthBloc>().add(const ResendVerificationEmailRequested());
    setState(() => _resent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email resent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 64),
              const SizedBox(height: 20),
              Text('Verify your email', style: AppTextStyles.headingMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                "We've sent a verification link to your email. Confirm it to unlock booking, "
                'circles, and chat.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SolaceButton(
                label: "I've verified my email",
                isLoading: _checking,
                onPressed: _checkStatus,
              ),
              const SizedBox(height: 12),
              SolaceButton(
                label: _resent ? 'Email resent' : 'Resend email',
                variant: SolaceButtonVariant.outline,
                onPressed: _resent ? null : _resend,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.read<AuthBloc>().add(const LogoutRequested()),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
