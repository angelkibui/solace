import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Before AuthBloc's authStateChanges subscription has reported anything —
/// shown briefly behind SplashScreen's own animation.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A login/register/Google-sign-in/reset request is in flight.
class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool emailVerified;
  const AuthAuthenticated(this.user, {this.emailVerified = true});

  @override
  List<Object?> get props => [user, emailVerified];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted once right after RegisterRequested succeeds, so RegisterScreen
/// can route to VerifyEmailScreen. AuthBloc moves on to AuthAuthenticated
/// right after via the authStateChanges subscription.
class EmailVerificationSent extends AuthState {
  const EmailVerificationSent();
}
