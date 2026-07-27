import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

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

class EmailVerificationSent extends AuthState {
  final UserModel user;
  const EmailVerificationSent(this.user);

  @override
  List<Object?> get props => [user];
}
