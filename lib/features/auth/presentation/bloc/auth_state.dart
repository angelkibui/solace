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
  final bool isUpdatingProfile;
  final String? profileErrorMessage;

  const AuthAuthenticated(
    this.user, {
    this.emailVerified = true,
    this.isUpdatingProfile = false,
    this.profileErrorMessage,
  });

  AuthAuthenticated copyWith({
    UserModel? user,
    bool? emailVerified,
    bool? isUpdatingProfile,
    String? profileErrorMessage,
    bool clearProfileError = false,
  }) {
    return AuthAuthenticated(
      user ?? this.user,
      emailVerified: emailVerified ?? this.emailVerified,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
      profileErrorMessage: clearProfileError
          ? null
          : profileErrorMessage ?? this.profileErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        user,
        emailVerified,
        isUpdatingProfile,
        profileErrorMessage,
      ];
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
