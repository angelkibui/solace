import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Internal — fired by AuthBloc's own subscription to
/// AuthRepository.authStateChanges. Not dispatched by the UI.
class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user?.uid];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String alias;
  final String email;
  final String password;

  /// Concerns picked on ConcernSelectionScreen (Part C3), read from
  /// OnboardingCubit by RegisterScreen. Seeds UserModel.preferences so
  /// Home's "Recommended for you" (Part E) has something to personalize
  /// against from the very first login.
  final List<String> preferences;

  const RegisterRequested({
    required this.alias,
    required this.email,
    required this.password,
    this.preferences = const [],
  });

  @override
  List<Object?> get props => [alias, email, password, preferences];
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// D5 — polled from VerifyEmailScreen's "I've verified my email" button.
class EmailVerificationCheckRequested extends AuthEvent {
  const EmailVerificationCheckRequested();
}

class ResendVerificationEmailRequested extends AuthEvent {
  const ResendVerificationEmailRequested();
}
