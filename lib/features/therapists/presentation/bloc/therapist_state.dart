import 'package:equatable/equatable.dart';

import '../../data/models/therapist_model.dart';

enum TherapistStatus { initial, loading, success, failure, refreshing }

class TherapistState extends Equatable {
  final TherapistStatus status;
  final List<TherapistModel> therapists;
  final String query;
  final String? specialty;
  final String? language;
  final String? gender;
  final int? maximumRate;
  final String? errorMessage;

  const TherapistState({
    this.status = TherapistStatus.initial,
    this.therapists = const [],
    this.query = '',
    this.specialty,
    this.language,
    this.gender,
    this.maximumRate,
    this.errorMessage,
  });

  List<TherapistModel> get visibleTherapists {
    final normalizedQuery = query.trim().toLowerCase();
    return therapists.where((therapist) {
      final matchesQuery = normalizedQuery.isEmpty ||
          therapist.name.toLowerCase().contains(normalizedQuery) ||
          therapist.title.toLowerCase().contains(normalizedQuery) ||
          therapist.specialties.any(
            (value) => value.toLowerCase().contains(normalizedQuery),
          );
      final matchesSpecialty = specialty == null ||
          therapist.specialties.contains(specialty) ||
          therapist.title == specialty;
      final matchesLanguage =
          language == null || therapist.languages.contains(language);
      final matchesGender = gender == null || therapist.gender == gender;
      final matchesRate = maximumRate == null || therapist.rate <= maximumRate!;
      return matchesQuery &&
          matchesSpecialty &&
          matchesLanguage &&
          matchesGender &&
          matchesRate;
    }).toList();
  }

  bool get hasActiveFilters =>
      specialty != null ||
      language != null ||
      gender != null ||
      maximumRate != null;

  TherapistState copyWith({
    TherapistStatus? status,
    List<TherapistModel>? therapists,
    String? query,
    String? specialty,
    String? language,
    String? gender,
    int? maximumRate,
    String? errorMessage,
    bool clearSpecialty = false,
    bool clearLanguage = false,
    bool clearGender = false,
    bool clearMaximumRate = false,
    bool clearError = false,
  }) {
    return TherapistState(
      status: status ?? this.status,
      therapists: therapists ?? this.therapists,
      query: query ?? this.query,
      specialty: clearSpecialty ? null : specialty ?? this.specialty,
      language: clearLanguage ? null : language ?? this.language,
      gender: clearGender ? null : gender ?? this.gender,
      maximumRate: clearMaximumRate ? null : maximumRate ?? this.maximumRate,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        therapists,
        query,
        specialty,
        language,
        gender,
        maximumRate,
        errorMessage,
      ];
}
