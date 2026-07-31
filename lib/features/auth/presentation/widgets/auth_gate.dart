import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/main_shell.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../pages/login_screen.dart';
import '../pages/register_screen.dart';
import '../pages/verify_email_screen.dart';

/// The single place that turns AuthBloc state into a screen. Everything
/// feature-specific that used to live here (TherapistBloc/AppointmentBloc/
/// PaymentBloc providers, the booking -> checkout navigation chain) moved
/// into MainShell once Home Dashboard's bottom-nav shell and the
/// Therapist/Appointment/Payment work (built in parallel) were reconciled
/// -- AuthGate now only decides *which top-level screen* to show, not what
/// any of them contain.
class AuthGate extends StatefulWidget {
  final bool startAtRegister;

  const AuthGate({super.key, this.startAtRegister = false});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool _showRegister = widget.startAtRegister;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthInitial() => const _AuthGateLoading(),
          EmailVerificationSent() => const VerifyEmailScreen(),
          AuthAuthenticated(emailVerified: false) => const VerifyEmailScreen(),
          AuthAuthenticated() => const MainShell(),
          AuthLoading() || AuthUnauthenticated() || AuthError() => _showRegister
              ? RegisterScreen(
                  onSwitchToLogin: () => setState(() => _showRegister = false),
                )
              : LoginScreen(
                  onSwitchToRegister: () =>
                      setState(() => _showRegister = true),
                ),
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
