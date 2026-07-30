import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../pages/login_screen.dart';
import '../pages/register_screen.dart';
import '../pages/verify_email_screen.dart';
import '../../../therapists/data/repositories/therapist_repository.dart';
import '../../../therapists/presentation/bloc/therapist_bloc.dart';
import '../../../therapists/presentation/bloc/therapist_event.dart';
import '../../../therapists/presentation/pages/therapist_list_screen.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';
import '../../../appointments/presentation/bloc/appointment_event.dart';
import '../../../appointments/presentation/pages/booking_flow_screen.dart';
import '../../../therapists/data/models/therapist_model.dart';

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
          AuthInitial() || AuthLoading() => const _AuthGateLoading(),
          EmailVerificationSent() => const VerifyEmailScreen(),
          AuthAuthenticated(emailVerified: false) => const VerifyEmailScreen(),
          AuthAuthenticated(user: final user) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => TherapistBloc(TherapistRepository())
                    ..add(const TherapistsRequested()),
                ),
                BlocProvider(
                  create: (_) => AppointmentBloc(AppointmentRepository())
                    ..add(AppointmentsRequested(user.uid)),
                ),
              ],
              child: _AuthenticatedExperience(userId: user.uid),
            ),
          AuthUnauthenticated() || AuthError() => _showRegister
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

class _AuthenticatedExperience extends StatelessWidget {
  final String userId;

  const _AuthenticatedExperience({required this.userId});

  @override
  Widget build(BuildContext context) {
    return TherapistListScreen(
      onBookTherapist: (therapist) => _openBooking(context, therapist),
    );
  }

  void _openBooking(BuildContext context, TherapistModel therapist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AppointmentBloc>(),
          child: BookingFlowScreen(userId: userId, therapist: therapist),
        ),
      ),
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
