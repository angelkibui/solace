import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Owns the entire session lifecycle: login, register, Google sign-in,
/// logout, password reset, and — via the [AuthRepository.authStateChanges]
/// subscription below — auto-login on app relaunch (D12). AuthGate
/// (presentation/widgets/auth_gate.dart) is the only widget that should
/// read this Bloc's state to decide what to show.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _authStateSubscription;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthUserChanged>(_onUserChanged);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<EmailVerificationCheckRequested>(_onEmailVerificationCheckRequested);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);

    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  Future<void> _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) async {
    final user = event.user;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    final userModel = await _authRepository.getUserModel(user.uid);
    if (userModel == null) {
      // Firebase Auth has a user but the Firestore doc hasn't been created
      // yet (mid-registration race) — stay unauthenticated rather than
      // crash on a null profile; the next authStateChanges tick will
      // resolve once registerWithEmail finishes writing the doc.
      emit(const AuthUnauthenticated());
      return;
    }

    emit(AuthAuthenticated(userModel, emailVerified: user.emailVerified));
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.loginWithEmail(email: event.email, password: event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user, emailVerified: _authRepository.currentUser?.emailVerified ?? false)),
    );
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.registerWithEmail(
      alias: event.alias,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const EmailVerificationSent()),
    );
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user, emailVerified: _authRepository.currentUser?.emailVerified ?? false)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    // No explicit emit here — signing out fires authStateChanges(null),
    // which _onUserChanged turns into AuthUnauthenticated.
  }

  Future<void> _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.sendPasswordResetEmail(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()), // back to a login-adjacent state; ForgotPasswordScreen shows its own success UI
    );
  }

  Future<void> _onEmailVerificationCheckRequested(
    EmailVerificationCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isVerified = await _authRepository.checkEmailVerified();
    final current = state;
    if (current is AuthAuthenticated) {
      emit(AuthAuthenticated(current.user, emailVerified: isVerified));
    }
  }

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.resendVerificationEmail();
    // Deliberately no state change: VerifyEmailScreen shows its own
    // "sent!" snackbar rather than the Bloc re-emitting the same state.
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
