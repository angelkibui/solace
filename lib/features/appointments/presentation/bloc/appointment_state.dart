import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/appointment_model.dart';

enum AppointmentStatusState { initial, loading, ready, submitting, failure }

class AppointmentState extends Equatable {
  final AppointmentStatusState status;
  final List<AppointmentModel> appointments;
  final Map<String, String> therapistNames;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final SessionType sessionType;
  final String notes;
  final int bookingStep;
  final AppointmentModel? lastCreatedAppointment;
  final String? actionMessage;
  final String? errorMessage;

  const AppointmentState({
    this.status = AppointmentStatusState.initial,
    this.appointments = const [],
    this.therapistNames = const {},
    this.selectedDate,
    this.selectedTime,
    this.sessionType = SessionType.individual,
    this.notes = '',
    this.bookingStep = 0,
    this.lastCreatedAppointment,
    this.actionMessage,
    this.errorMessage,
  });

  DateTime? get selectedDateTime {
    if (selectedDate == null || selectedTime == null) return null;
    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
  }

  bool get canContinue => switch (bookingStep) {
        0 => selectedDate != null,
        1 => selectedTime != null,
        2 => true,
        _ => selectedDateTime != null,
      };

  AppointmentState copyWith({
    AppointmentStatusState? status,
    List<AppointmentModel>? appointments,
    Map<String, String>? therapistNames,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    SessionType? sessionType,
    String? notes,
    int? bookingStep,
    AppointmentModel? lastCreatedAppointment,
    String? actionMessage,
    String? errorMessage,
    bool clearDraft = false,
    bool clearLastCreated = false,
    bool clearActionMessage = false,
    bool clearError = false,
  }) {
    return AppointmentState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      therapistNames: therapistNames ?? this.therapistNames,
      selectedDate: clearDraft ? null : selectedDate ?? this.selectedDate,
      selectedTime: clearDraft ? null : selectedTime ?? this.selectedTime,
      sessionType:
          clearDraft ? SessionType.individual : sessionType ?? this.sessionType,
      notes: clearDraft ? '' : notes ?? this.notes,
      bookingStep: clearDraft ? 0 : bookingStep ?? this.bookingStep,
      lastCreatedAppointment: clearLastCreated
          ? null
          : lastCreatedAppointment ?? this.lastCreatedAppointment,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        appointments,
        therapistNames,
        selectedDate,
        selectedTime,
        sessionType,
        notes,
        bookingStep,
        lastCreatedAppointment,
        actionMessage,
        errorMessage,
      ];
}
