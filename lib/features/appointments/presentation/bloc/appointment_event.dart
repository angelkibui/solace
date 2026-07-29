import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/appointment_model.dart';

sealed class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class AppointmentsRequested extends AppointmentEvent {
  final String userId;

  const AppointmentsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class BookingDateSelected extends AppointmentEvent {
  final DateTime date;

  const BookingDateSelected(this.date);

  @override
  List<Object?> get props => [date];
}

class BookingTimeSelected extends AppointmentEvent {
  final TimeOfDay time;

  const BookingTimeSelected(this.time);

  @override
  List<Object?> get props => [time];
}

class BookingSessionTypeSelected extends AppointmentEvent {
  final SessionType sessionType;

  const BookingSessionTypeSelected(this.sessionType);

  @override
  List<Object?> get props => [sessionType];
}

class BookingNotesChanged extends AppointmentEvent {
  final String notes;

  const BookingNotesChanged(this.notes);

  @override
  List<Object?> get props => [notes];
}

class BookingStepChanged extends AppointmentEvent {
  final int step;

  const BookingStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class BookingDraftCleared extends AppointmentEvent {
  const BookingDraftCleared();
}

class AppointmentCreateRequested extends AppointmentEvent {
  final String userId;
  final String therapistId;
  final int amount;

  const AppointmentCreateRequested({
    required this.userId,
    required this.therapistId,
    required this.amount,
  });

  @override
  List<Object?> get props => [userId, therapistId, amount];
}

class AppointmentRescheduleRequested extends AppointmentEvent {
  final AppointmentModel appointment;
  final DateTime dateTime;

  const AppointmentRescheduleRequested(this.appointment, this.dateTime);

  @override
  List<Object?> get props => [appointment, dateTime];
}

class AppointmentCancelRequested extends AppointmentEvent {
  final AppointmentModel appointment;

  const AppointmentCancelRequested(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class AppointmentDeleteRequested extends AppointmentEvent {
  final String appointmentId;

  const AppointmentDeleteRequested(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}
