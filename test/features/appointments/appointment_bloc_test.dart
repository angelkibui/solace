import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/appointments/data/models/appointment_model.dart';
import 'package:solace/features/appointments/data/repositories/appointment_repository.dart';
import 'package:solace/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:solace/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:solace/features/appointments/presentation/bloc/appointment_state.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

class FakeAppointmentModel extends Fake implements AppointmentModel {}

void main() {
  late MockAppointmentRepository repository;
  final selectedDate = DateTime(2026, 8, 4);
  const selectedTime = TimeOfDay(hour: 10, minute: 30);
  final appointment = AppointmentModel(
    id: 'appointment-1',
    userId: 'user-1',
    therapistId: 'therapist-1',
    dateTime: DateTime(2026, 8, 4, 10, 30),
    sessionType: SessionType.individual,
    status: AppointmentStatus.pendingPayment,
    amount: 35000,
    notes: 'First session',
    createdAt: DateTime(2026, 7, 30, 9),
    updatedAt: DateTime(2026, 7, 30, 9),
  );

  setUpAll(() {
    registerFallbackValue(FakeAppointmentModel());
  });

  setUp(() {
    repository = MockAppointmentRepository();
  });

  blocTest<AppointmentBloc, AppointmentState>(
    'loads appointments and resolves professional names',
    setUp: () {
      when(() => repository.getAppointments('user-1')).thenAnswer(
        (_) async => Success([appointment]),
      );
      when(() => repository.getTherapistNames(any())).thenAnswer(
        (_) async => const Success({'therapist-1': 'Dr. Aline Mutoni'}),
      );
    },
    build: () => AppointmentBloc(repository),
    act: (bloc) => bloc.add(const AppointmentsRequested('user-1')),
    expect: () => [
      const AppointmentState(status: AppointmentStatusState.loading),
      AppointmentState(
        status: AppointmentStatusState.ready,
        appointments: [appointment],
        therapistNames: const {'therapist-1': 'Dr. Aline Mutoni'},
      ),
    ],
  );

  blocTest<AppointmentBloc, AppointmentState>(
    'creates an appointment from the booking draft',
    setUp: () {
      when(() => repository.createAppointment(any())).thenAnswer(
        (_) async => Success(appointment),
      );
    },
    seed: () => AppointmentState(
      selectedDate: selectedDate,
      selectedTime: selectedTime,
      notes: 'First session',
    ),
    build: () => AppointmentBloc(repository),
    act: (bloc) => bloc.add(
      const AppointmentCreateRequested(
        userId: 'user-1',
        therapistId: 'therapist-1',
        amount: 35000,
      ),
    ),
    expect: () => [
      AppointmentState(
        status: AppointmentStatusState.submitting,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        notes: 'First session',
      ),
      AppointmentState(
        status: AppointmentStatusState.ready,
        appointments: [appointment],
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        notes: 'First session',
        lastCreatedAppointment: appointment,
        actionMessage: 'Appointment reserved. Complete payment to confirm it.',
      ),
    ],
    verify: (_) {
      final captured = verify(() => repository.createAppointment(captureAny()))
          .captured
          .single as AppointmentModel;
      expect(captured.userId, 'user-1');
      expect(captured.therapistId, 'therapist-1');
      expect(captured.dateTime, DateTime(2026, 8, 4, 10, 30));
      expect(captured.status, AppointmentStatus.pendingPayment);
    },
  );

  blocTest<AppointmentBloc, AppointmentState>(
    'removes a deleted appointment immediately',
    setUp: () {
      when(() => repository.deleteAppointment('appointment-1')).thenAnswer(
        (_) async => const Success(null),
      );
    },
    seed: () => AppointmentState(
      status: AppointmentStatusState.ready,
      appointments: [appointment],
    ),
    build: () => AppointmentBloc(repository),
    act: (bloc) => bloc.add(const AppointmentDeleteRequested('appointment-1')),
    expect: () => [
      AppointmentState(
        status: AppointmentStatusState.submitting,
        appointments: [appointment],
      ),
      const AppointmentState(
        status: AppointmentStatusState.ready,
        actionMessage: 'Appointment removed.',
      ),
    ],
  );
}
