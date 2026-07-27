import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/placeholder_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../pages/login_screen.dart';
import '../pages/register_screen.dart';
import '../pages/verify_email_screen.dart';

/// The single place that turns AuthBloc state into a screen. SplashScreen
/// and FindMatchPreviewScreen both navigate here rather than to
/// LoginScreen directly (D12): if Firebase already has a cached session,
/// AuthBloc's authStateChanges subscription resolves to AuthAuthenticated
/// almost immediately and this widget skips straight past login.
///
/// TEMPORARY: the authenticated branch renders PlaceholderScreen until
/// Part E (Home Dashboard) exists — swap it for the real Home screen then.
class AuthGate extends StatelessWidget {
  /// FindMatchPreviewScreen sets this after onboarding completes, since a
  /// brand-new user needs Register, not Login. Ignored once a session
  /// exists (a cached login always wins over this hint).
  final bool startAtRegister;

  const AuthGate({super.key, this.startAtRegister = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthInitial() || AuthLoading() => const _AuthGateLoading(),
          AuthAuthenticated(emailVerified: false) => const VerifyEmailScreen(),
          AuthAuthenticated() => const PlaceholderScreen(message: "You're verified! Next up: Home Dashboard (Part E)."),
          AuthUnauthenticated() || AuthError() || EmailVerificationSent() =>
            startAtRegister ? const RegisterScreen() : const LoginScreen(),
        };
      },
    );
  }
}

class _AuthGateLoading extends StatelessWidget {
  const _AuthGateLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
