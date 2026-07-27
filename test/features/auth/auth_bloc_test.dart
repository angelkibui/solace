import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/utils/failure.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/auth/data/models/user_model.dart';
import 'package:solace/features/auth/data/repositories/auth_repository.dart';
import 'package:solace/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:solace/features/auth/presentation/bloc/auth_event.dart';
import 'package:solace/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository authRepository;

  final testUser = UserModel(
    uid: 'uid-1',
    alias: 'BraveRiver12345',
    email: 'kevin@example.com',
    createdAt: DateTime(2026, 1, 1),
    onboardingComplete: true,
  );

  setUp(() {
    authRepository = MockAuthRepository();
    // Every AuthBloc subscribes to this in its constructor (Part D12) —
    // stub it for every test so the Bloc can even be constructed.
    when(() => authRepository.authStateChanges).thenAnswer((_) => const Stream<User?>.empty());
    when(() => authRepository.currentUser).thenReturn(null);
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      setUp: () {
        when(() => authRepository.loginWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => Success(testUser));
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(const LoginRequested(email: 'kevin@example.com', password: 'password1')),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(testUser, emailVerified: false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failed login',
      setUp: () {
        when(() => authRepository.loginWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => const ResultError(AuthFailure('Incorrect email or password.')));
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(const LoginRequested(email: 'kevin@example.com', password: 'wrong')),
      expect: () => [
        const AuthLoading(),
        const AuthError('Incorrect email or password.'),
      ],
    );
  });

  group('RegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, EmailVerificationSent] on successful registration',
      setUp: () {
        when(() => authRepository.registerWithEmail(
              alias: any(named: 'alias'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => Success(testUser));
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(
        const RegisterRequested(alias: 'BraveRiver12345', email: 'kevin@example.com', password: 'password1'),
      ),
      expect: () => [
        const AuthLoading(),
        const EmailVerificationSent(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when the email is already in use',
      setUp: () {
        when(() => authRepository.registerWithEmail(
              alias: any(named: 'alias'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => const ResultError(AuthFailure('An account already exists with that email.')));
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(
        const RegisterRequested(alias: 'BraveRiver12345', email: 'kevin@example.com', password: 'password1'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('An account already exists with that email.'),
      ],
    );
  });

  group('AuthUserChanged (auto-login, D12)', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated when Firebase reports no user',
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(const AuthUserChanged(null)),
      expect: () => [const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated when a cached session resolves to a known user doc',
      setUp: () {
        when(() => authRepository.getUserModel(any())).thenAnswer((_) async => testUser);
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) {
        final mockUser = MockUser();
        when(() => mockUser.uid).thenReturn('uid-1');
        when(() => mockUser.emailVerified).thenReturn(true);
        bloc.add(AuthUserChanged(mockUser));
      },
      expect: () => [AuthAuthenticated(testUser, emailVerified: true)],
    );
  });
}
