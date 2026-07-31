import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointment_repository.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository _repository;

  AppointmentBloc(this._repository) : super(const AppointmentState()) {
    on<AppointmentsRequested>(_onAppointmentsRequested);
    on<BookingDateSelected>(
        (event, emit) => emit(state.copyWith(selectedDate: event.date)));
    on<BookingTimeSelected>(
        (event, emit) => emit(state.copyWith(selectedTime: event.time)));
    on<BookingSessionTypeSelected>(
      (event, emit) => emit(state.copyWith(sessionType: event.sessionType)),
    );
    on<BookingNotesChanged>(
        (event, emit) => emit(state.copyWith(notes: event.notes)));
    on<BookingStepChanged>(
        (event, emit) => emit(state.copyWith(bookingStep: event.step)));
    on<BookingDraftCleared>(
        (event, emit) => emit(state.copyWith(clearDraft: true)));
    on<AppointmentCreateRequested>(_onCreateRequested);
    on<AppointmentRescheduleRequested>(_onRescheduleRequested);
    on<AppointmentCancelRequested>(_onCancelRequested);
    on<AppointmentDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onAppointmentsRequested(
    AppointmentsRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(state.copyWith(
        status: AppointmentStatusState.loading, clearError: true));
    final result = await _repository.getAppointments(event.userId);
    switch (result) {
      case Success(data: final appointments):
        final namesResult = await _repository.getTherapistNames(
          appointments.map((appointment) => appointment.therapistId),
        );
        final names = namesResult.dataOrNull ?? const <String, String>{};
        emit(state.copyWith(
          status: AppointmentStatusState.ready,
          appointments: appointments,
          therapistNames: names,
        ));
      case ResultError(failure: final failure):
        emit(state.copyWith(
          status: AppointmentStatusState.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> _onCreateRequested(
    AppointmentCreateRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    final dateTime = state.selectedDateTime;
    if (dateTime == null) {
      emit(state.copyWith(
        status: AppointmentStatusState.failure,
        errorMessage: 'Choose a date and time before continuing.',
      ));
      return;
    }

    emit(state.copyWith(
      status: AppointmentStatusState.submitting,
      clearError: true,
      clearActionMessage: true,
    ));
    final now = DateTime.now();
    final appointment = AppointmentModel(
      id: '',
      userId: event.userId,
      therapistId: event.therapistId,
      dateTime: dateTime,
      sessionType: state.sessionType,
      status: AppointmentStatus.pendingPayment,
      amount: event.amount,
      notes: state.notes.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final result = await _repository.createAppointment(appointment);
    switch (result) {
      case Success(data: final created):
        emit(state.copyWith(
          status: AppointmentStatusState.ready,
          appointments: [...state.appointments, created]
            ..sort((left, right) => left.dateTime.compareTo(right.dateTime)),
          lastCreatedAppointment: created,
          actionMessage:
              'Appointment reserved. Complete payment to confirm it.',
        ));
      case ResultError(failure: final failure):
        emit(state.copyWith(
          status: AppointmentStatusState.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> _onRescheduleRequested(
    AppointmentRescheduleRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(state.copyWith(
        status: AppointmentStatusState.submitting, clearError: true));
    final result = await _repository.rescheduleAppointment(
        event.appointment, event.dateTime);
    _emitUpdateResult(
      result,
      emit,
      successMessage: 'Appointment rescheduled.',
    );
  }

  Future<void> _onCancelRequested(
    AppointmentCancelRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(state.copyWith(
        status: AppointmentStatusState.submitting, clearError: true));
    final result = await _repository.updateStatus(
      event.appointment,
      AppointmentStatus.cancelled,
    );
    _emitUpdateResult(result, emit, successMessage: 'Appointment cancelled.');
  }

  Future<void> _onDeleteRequested(
    AppointmentDeleteRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(state.copyWith(
        status: AppointmentStatusState.submitting, clearError: true));
    final result = await _repository.deleteAppointment(event.appointmentId);
    switch (result) {
      case Success():
        emit(state.copyWith(
          status: AppointmentStatusState.ready,
          appointments: state.appointments
              .where((appointment) => appointment.id != event.appointmentId)
              .toList(),
          actionMessage: 'Appointment removed.',
        ));
      case ResultError(failure: final failure):
        emit(state.copyWith(
          status: AppointmentStatusState.failure,
          errorMessage: failure.message,
        ));
    }
  }

  void _emitUpdateResult(
    Result<AppointmentModel> result,
    Emitter<AppointmentState> emit, {
    required String successMessage,
  }) {
    switch (result) {
      case Success(data: final updated):
        emit(state.copyWith(
          status: AppointmentStatusState.ready,
          appointments: state.appointments
              .map((appointment) =>
                  appointment.id == updated.id ? updated : appointment)
              .toList(),
          actionMessage: successMessage,
        ));
      case ResultError(failure: final failure):
        emit(state.copyWith(
          status: AppointmentStatusState.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
