import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/appointments/data/models/appointment_model.dart';
import 'package:solace/features/appointments/data/repositories/appointment_repository.dart';

void main() {
  test('persists the full appointment CRUD lifecycle', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = AppointmentRepository(firestore: firestore);
    await firestore.collection('therapists').doc('therapist-1').set({
      'name': 'Dr. Aline Mutoni',
    });
    final appointment = AppointmentModel(
      id: '',
      userId: 'user-1',
      therapistId: 'therapist-1',
      dateTime: DateTime.utc(2026, 8, 4, 10, 30),
      sessionType: SessionType.individual,
      status: AppointmentStatus.pendingPayment,
      amount: 35000,
      notes: 'First session',
      createdAt: DateTime.utc(2026, 7, 30),
      updatedAt: DateTime.utc(2026, 7, 30),
    );

    final created =
        (await repository.createAppointment(appointment)).dataOrNull;
    expect(created?.id, isNotEmpty);

    final appointments =
        (await repository.getAppointments('user-1')).dataOrNull;
    expect(appointments, hasLength(1));
    expect(appointments!.single.notes, 'First session');

    final names = (await repository.getTherapistNames([
      'therapist-1',
      'therapist-1',
      '',
    ]))
        .dataOrNull;
    expect(names, {'therapist-1': 'Dr. Aline Mutoni'});

    final newDate = DateTime.utc(2026, 8, 6, 13);
    final rescheduled =
        (await repository.rescheduleAppointment(created!, newDate)).dataOrNull;
    expect(rescheduled?.dateTime, newDate);

    final confirmed = (await repository.updateStatus(
      rescheduled!,
      AppointmentStatus.confirmed,
    ))
        .dataOrNull;
    expect(confirmed?.status, AppointmentStatus.confirmed);

    final persisted =
        await firestore.collection('appointments').doc(created.id).get();
    expect(persisted.data()?['status'], 'confirmed');

    expect((await repository.deleteAppointment(created.id)).isSuccess, isTrue);
    expect(
      (await repository.getAppointments('user-1')).dataOrNull,
      isEmpty,
    );
  });
}
