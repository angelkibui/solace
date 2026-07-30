import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/appointments/data/models/appointment_model.dart';
import 'package:solace/features/payments/data/models/transaction_model.dart';
import 'package:solace/features/payments/data/repositories/payment_repository.dart';
import 'package:solace/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:solace/features/payments/presentation/bloc/payment_event.dart';
import 'package:solace/features/payments/presentation/bloc/payment_state.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

class FakeTransactionModel extends Fake implements TransactionModel {}

void main() {
  late MockPaymentRepository repository;
  final appointment = AppointmentModel(
    id: 'appointment-1',
    userId: 'user-1',
    therapistId: 'therapist-1',
    dateTime: DateTime(2026, 8, 4, 10, 30),
    sessionType: SessionType.individual,
    status: AppointmentStatus.pendingPayment,
    amount: 35000,
    notes: '',
    createdAt: DateTime(2026, 7, 30),
    updatedAt: DateTime(2026, 7, 30),
  );

  setUpAll(() {
    registerFallbackValue(FakeTransactionModel());
    registerFallbackValue(TransactionStatus.pending);
  });

  setUp(() {
    repository = MockPaymentRepository();
  });

  blocTest<PaymentBloc, PaymentState>(
    'completes checkout, updates history, and clears the PIN',
    setUp: () {
      when(() => repository.createTransaction(any()))
          .thenAnswer((invocation) async {
        final pending =
            invocation.positionalArguments.single as TransactionModel;
        return Success(pending.copyWith(id: 'transaction-1'));
      });
      when(
        () => repository.completeTransaction(
          any(),
          TransactionStatus.successful,
        ),
      ).thenAnswer((invocation) async {
        final pending =
            invocation.positionalArguments.first as TransactionModel;
        return Success(pending.copyWith(status: TransactionStatus.successful));
      });
    },
    seed: () => const PaymentState(
      status: PaymentProcessStatus.ready,
      phoneNumber: '0780000000',
      pin: '12345',
    ),
    build: () => PaymentBloc(repository, processingDelay: Duration.zero),
    act: (bloc) => bloc.add(PaymentSubmitted(appointment)),
    wait: const Duration(milliseconds: 20),
    expect: () => [
      isA<PaymentState>().having(
        (state) => state.status,
        'status',
        PaymentProcessStatus.processing,
      ),
      isA<PaymentState>()
          .having(
            (state) => state.status,
            'status',
            PaymentProcessStatus.success,
          )
          .having((state) => state.pin, 'cleared PIN', isEmpty)
          .having((state) => state.transactions.length, 'history size', 1)
          .having(
            (state) => state.currentTransaction?.status,
            'transaction status',
            TransactionStatus.successful,
          ),
    ],
    verify: (_) {
      verify(() => repository.createTransaction(any())).called(1);
      verify(
        () => repository.completeTransaction(
          any(),
          TransactionStatus.successful,
        ),
      ).called(1);
    },
  );

  blocTest<PaymentBloc, PaymentState>(
    'rejects invalid checkout fields without creating a transaction',
    seed: () => const PaymentState(
      status: PaymentProcessStatus.ready,
      phoneNumber: '123',
      pin: '12',
    ),
    build: () => PaymentBloc(repository, processingDelay: Duration.zero),
    act: (bloc) => bloc.add(PaymentSubmitted(appointment)),
    expect: () => [
      isA<PaymentState>()
          .having(
            (state) => state.status,
            'status',
            PaymentProcessStatus.failure,
          )
          .having(
            (state) => state.errorMessage,
            'message',
            'Enter a valid Rwandan phone number.',
          ),
    ],
    verify: (_) => verifyNever(() => repository.createTransaction(any())),
  );

  blocTest<PaymentBloc, PaymentState>(
    'loads and deletes transaction history',
    setUp: () {
      final transaction = TransactionModel(
        id: 'transaction-1',
        transactionId: 'SOL-123',
        userId: 'user-1',
        amount: 35000,
        network: PaymentNetwork.mtn,
        status: TransactionStatus.successful,
        timestamp: DateTime(2026, 7, 30),
        appointmentId: 'appointment-1',
      );
      when(() => repository.getTransactions('user-1')).thenAnswer(
        (_) async => Success([transaction]),
      );
      when(() => repository.deleteTransaction('transaction-1')).thenAnswer(
        (_) async => const Success(null),
      );
    },
    build: () => PaymentBloc(repository, processingDelay: Duration.zero),
    act: (bloc) async {
      bloc.add(const TransactionsRequested('user-1'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const TransactionDeleteRequested('transaction-1'));
    },
    expect: () => [
      isA<PaymentState>().having(
        (state) => state.status,
        'status',
        PaymentProcessStatus.loading,
      ),
      isA<PaymentState>()
          .having(
            (state) => state.status,
            'status',
            PaymentProcessStatus.ready,
          )
          .having((state) => state.transactions.length, 'history size', 1),
      isA<PaymentState>()
          .having(
            (state) => state.status,
            'status',
            PaymentProcessStatus.ready,
          )
          .having((state) => state.transactions, 'history', isEmpty),
    ],
  );
}
