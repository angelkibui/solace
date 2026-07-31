import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/appointments/data/models/appointment_model.dart';
import 'package:solace/features/payments/data/models/transaction_model.dart';
import 'package:solace/features/payments/data/repositories/payment_repository.dart';

void main() {
  test('persists payment status, history, and appointment confirmation',
      () async {
    final firestore = FakeFirebaseFirestore();
    final repository = PaymentRepository(firestore: firestore);
    final appointment = AppointmentModel(
      id: 'appointment-1',
      userId: 'user-1',
      therapistId: 'therapist-1',
      dateTime: DateTime.utc(2026, 8, 4, 10, 30),
      sessionType: SessionType.individual,
      status: AppointmentStatus.pendingPayment,
      amount: 35000,
      notes: '',
      createdAt: DateTime.utc(2026, 7, 30),
      updatedAt: DateTime.utc(2026, 7, 30),
    );
    await firestore
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toMap());
    final transaction = TransactionModel(
      id: '',
      transactionId: 'SOL-123',
      userId: 'user-1',
      amount: 35000,
      network: PaymentNetwork.mtn,
      status: TransactionStatus.pending,
      timestamp: DateTime.utc(2026, 7, 31, 8),
      appointmentId: appointment.id,
    );

    final created =
        (await repository.createTransaction(transaction)).dataOrNull;
    expect(created?.id, isNotEmpty);

    final completed = (await repository.completeTransaction(
      created!,
      TransactionStatus.successful,
    ))
        .dataOrNull;
    expect(completed?.status, TransactionStatus.successful);

    final persistedAppointment =
        await firestore.collection('appointments').doc(appointment.id).get();
    expect(persistedAppointment.data()?['status'], 'confirmed');

    final history = (await repository.getTransactions('user-1')).dataOrNull;
    expect(history, hasLength(1));
    expect(history!.single.transactionId, 'SOL-123');
    expect(history.single.status, TransactionStatus.successful);

    expect((await repository.deleteTransaction(created.id)).isSuccess, isTrue);
    expect(
      (await repository.getTransactions('user-1')).dataOrNull,
      isEmpty,
    );
  });
}
