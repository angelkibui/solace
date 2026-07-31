import 'package:equatable/equatable.dart';

sealed class TherapistEvent extends Equatable {
  const TherapistEvent();

  @override
  List<Object?> get props => [];
}

class TherapistsRequested extends TherapistEvent {
  final bool refresh;

  const TherapistsRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class TherapistSearchChanged extends TherapistEvent {
  final String query;

  const TherapistSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class TherapistFiltersChanged extends TherapistEvent {
  final String? specialty;
  final String? language;
  final String? gender;
  final int? maximumRate;

  const TherapistFiltersChanged({
    this.specialty,
    this.language,
    this.gender,
    this.maximumRate,
  });

  @override
  List<Object?> get props => [specialty, language, gender, maximumRate];
}

class TherapistFiltersCleared extends TherapistEvent {
  const TherapistFiltersCleared();
}
