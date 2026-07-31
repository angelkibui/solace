import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String alias;
  final String email;
  final DateTime createdAt;

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
      createdAt:
          rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : DateTime.now(),
      preferences: List<String>.from(map['preferences'] as List? ?? const []),
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
    );
  }

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
  List<Object?> get props =>
      [uid, alias, email, createdAt, preferences, onboardingComplete];
}
