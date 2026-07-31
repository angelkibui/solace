import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/repositories/therapist_repository.dart';
import 'therapist_event.dart';
import 'therapist_state.dart';

class TherapistBloc extends Bloc<TherapistEvent, TherapistState> {
  final TherapistRepository _repository;

  TherapistBloc(this._repository) : super(const TherapistState()) {
    on<TherapistsRequested>(_onTherapistsRequested);
    on<TherapistSearchChanged>(_onSearchChanged);
    on<TherapistFiltersChanged>(_onFiltersChanged);
    on<TherapistFiltersCleared>(_onFiltersCleared);
  }

  Future<void> _onTherapistsRequested(
    TherapistsRequested event,
    Emitter<TherapistState> emit,
  ) async {
    emit(
      state.copyWith(
        status: event.refresh
            ? TherapistStatus.refreshing
            : TherapistStatus.loading,
        clearError: true,
      ),
    );
    final result = await _repository.getTherapists();
    switch (result) {
      case Success(data: final therapists):
        emit(
          state.copyWith(
            status: TherapistStatus.success,
            therapists: therapists,
          ),
        );
      case ResultError(failure: final failure):
        emit(
          state.copyWith(
            status: TherapistStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  void _onSearchChanged(
    TherapistSearchChanged event,
    Emitter<TherapistState> emit,
  ) {
    emit(state.copyWith(query: event.query));
  }

  void _onFiltersChanged(
    TherapistFiltersChanged event,
    Emitter<TherapistState> emit,
  ) {
    emit(
      state.copyWith(
        specialty: event.specialty,
        language: event.language,
        gender: event.gender,
        maximumRate: event.maximumRate,
        clearSpecialty: event.specialty == null,
        clearLanguage: event.language == null,
        clearGender: event.gender == null,
        clearMaximumRate: event.maximumRate == null,
      ),
    );
  }

  void _onFiltersCleared(
    TherapistFiltersCleared event,
    Emitter<TherapistState> emit,
  ) {
    emit(
      TherapistState(
        status: state.status,
        therapists: state.therapists,
        query: state.query,
      ),
    );
  }
}
