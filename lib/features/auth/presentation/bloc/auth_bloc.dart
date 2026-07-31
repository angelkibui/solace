import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

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

  Future<void> _onUserChanged(
      AuthUserChanged event, Emitter<AuthState> emit) async {
    final user = event.user;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    final userModel = await _authRepository.getUserModel(user.uid);
    if (userModel == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(AuthAuthenticated(userModel, emailVerified: user.emailVerified));
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.loginWithEmail(
        email: event.email, password: event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user,
          emailVerified: _authRepository.currentUser?.emailVerified ?? false)),
    );
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.registerWithEmail(
      alias: event.alias,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(EmailVerificationSent(user)),
    );
  }

  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user,
          emailVerified: _authRepository.currentUser?.emailVerified ?? false)),
    );
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
  }

  Future<void> _onPasswordResetRequested(
      PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _authRepository.sendPasswordResetEmail(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onEmailVerificationCheckRequested(
    EmailVerificationCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    final user = switch (current) {
      AuthAuthenticated(user: final u) => u,
      EmailVerificationSent(user: final u) => u,
      _ => null,
    };
    if (user == null) return;

    final isVerified = await _authRepository.checkEmailVerified();
    emit(AuthAuthenticated(user, emailVerified: isVerified));
  }

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.resendVerificationEmail();
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
