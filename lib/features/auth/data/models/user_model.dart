import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// The `users/{uid}` Firestore document (Part D1). [alias] — not [email] —
/// is the identity shown everywhere else in the app (TherapistCard reviews,
/// ChatBubble senders, CircleCard members) so the anonymity promise from
/// onboarding actually holds once someone is logged in.
class UserModel extends Equatable {
  final String uid;
  final String alias;
  final String email;
  final DateTime createdAt;

  /// Mental-health concerns selected during onboarding (Part C's
  /// ConcernChip screen) or later in Profile. Drives Home's "Recommended
  /// for you" therapist list (Part E) and therapist filtering (Part F).
  final List<String> preferences;

  final bool onboardingComplete;

  const UserModel({
    required this.uid,
    required this.alias,
    required this.email,
    required this.createdAt,
    this.preferences = const [],
    this.onboardingComplete = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    final rawCreatedAt = map['createdAt'];
    return UserModel(
      uid: uid,
      alias: map['alias'] as String? ?? 'Anonymous',
      email: map['email'] as String? ?? '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : DateTime.now(),
      preferences: List<String>.from(map['preferences'] as List? ?? const []),
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
    );
  }

  /// Excludes [uid] — that's the document ID, not a field, so it's never
  /// written into the document body.
  Map<String, dynamic> toMap() {
    return {
      'alias': alias,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': preferences,
      'onboardingComplete': onboardingComplete,
    };
  }

  UserModel copyWith({
    String? alias,
    String? email,
    List<String>? preferences,
    bool? onboardingComplete,
  }) {
    return UserModel(
      uid: uid,
      alias: alias ?? this.alias,
      email: email ?? this.email,
      createdAt: createdAt,
      preferences: preferences ?? this.preferences,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  List<Object?> get props => [uid, alias, email, createdAt, preferences, onboardingComplete];
}
