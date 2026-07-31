import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/utils/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/validators.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Result<UserModel>> registerWithEmail({
    required String email,
    required String password,
    required String alias,
    List<String> preferences = const [],
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const ResultError(
            AuthFailure('Registration failed. Please try again.'));
      }

      await user.sendEmailVerification();

      final model = UserModel(
        uid: user.uid,
        alias: alias.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
        preferences: preferences,
        onboardingComplete: true,
      );
      await _usersCollection.doc(user.uid).set(model.toMap());

      return Success(model);
    } on FirebaseAuthException catch (e) {
      return ResultError(AuthFailure(_messageForAuthCode(e.code)));
    } on FirebaseException catch (e) {
      return ResultError(ServerFailure(
          e.message ?? 'Could not save your account. Please try again.'));
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  Future<Result<UserModel>> loginWithEmail(
      {required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const ResultError(
            AuthFailure('Login failed. Please try again.'));
      }

      return Success(await _fetchOrCreateUserDoc(user));
    } on FirebaseAuthException catch (e) {
      return ResultError(AuthFailure(_messageForAuthCode(e.code)));
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const ResultError(AuthFailure('Google sign-in was cancelled.'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return const ResultError(
            AuthFailure('Google sign-in failed. Please try again.'));
      }

      return Success(
          await _fetchOrCreateUserDoc(user, fallbackEmail: googleUser.email));
    } on FirebaseAuthException catch (e) {
      return ResultError(AuthFailure(_messageForAuthCode(e.code)));
    } catch (_) {
      return const ResultError(
          AuthFailure('Google sign-in failed. Please try again.'));
    }
  }

  Future<Result<void>> resendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const ResultError(
            AuthFailure('You need to be signed in to do that.'));
      }
      await user.sendEmailVerification();
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return ResultError(AuthFailure(_messageForAuthCode(e.code)));
    }
  }

  Future<bool> checkEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  /// Forgot-password email.
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return ResultError(AuthFailure(_messageForAuthCode(e.code)));
    }
  }

  Future<void> logout() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  /// Updates the user's alias and/or preferences in Firestore.
  Future<Result<UserModel>> updateProfile({
    required String alias,
    required List<String> preferences,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const ResultError(
        AuthFailure('Sign in again before updating your profile.'),
      );
    }
    final normalizedAlias = alias.trim();
    final aliasError = Validators.alias(normalizedAlias);
    if (aliasError != null) {
      return ResultError(AuthFailure(aliasError));
    }
    final normalizedPreferences = preferences
        .map((preference) => preference.trim())
        .where((preference) => preference.isNotEmpty)
        .toSet()
        .take(20)
        .toList();

    try {
      await _usersCollection.doc(user.uid).update({
        'alias': normalizedAlias,
        'preferences': normalizedPreferences,
      });
      final updated = await getUserModel(user.uid);
      if (updated == null) {
        return const ResultError(
            ServerFailure('Could not reload your profile.'));
      }
      return Success(updated);
    } on FirebaseException catch (e) {
      return ResultError(
          ServerFailure(e.message ?? 'Could not save your profile.'));
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  Future<UserModel> _fetchOrCreateUserDoc(User user,
      {String? fallbackEmail}) async {
    final doc = await _usersCollection.doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, user.uid);
    }

    final model = UserModel(
      uid: user.uid,
      alias: _generateFallbackAlias(),
      email: user.email ?? fallbackEmail ?? '',
      createdAt: DateTime.now(),
      onboardingComplete: true,
    );
    await _usersCollection.doc(user.uid).set(model.toMap());
    return model;
  }

  static const _aliasAdjectives = [
    'Quiet',
    'Gentle',
    'Calm',
    'Brave',
    'Wise',
    'Kind',
    'Steady',
    'Bright',
    'Warm',
    'Bold',
  ];
  static const _aliasNouns = [
    'Forest',
    'River',
    'Mountain',
    'Ocean',
    'Sky',
    'Meadow',
    'Harbor',
    'Willow',
    'Ember',
    'Dawn',
  ];

  String _generateFallbackAlias() {
    final random = Random();
    final adjective = _aliasAdjectives[random.nextInt(_aliasAdjectives.length)];
    final noun = _aliasNouns[random.nextInt(_aliasNouns.length)];
    final number = random.nextInt(90000) + 10000;
    return '$adjective$noun$number';
  }

  String _messageForAuthCode(String code) {
    return switch (code) {
      'invalid-email' => 'That email address doesn\'t look right.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account found with that email.',
      'wrong-password' ||
      'invalid-credential' =>
        'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists with that email.',
      'weak-password' => 'Please choose a stronger password.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'No internet connection. Check your network and try again.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
