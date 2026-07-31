import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solace/core/theme/app_theme.dart';
import 'package:solace/features/appointments/data/models/appointment_model.dart';
import 'package:solace/features/appointments/data/repositories/appointment_repository.dart';
import 'package:solace/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:solace/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:solace/features/appointments/presentation/pages/appointment_confirmation_screen.dart';
import 'package:solace/features/appointments/presentation/pages/my_appointments_screen.dart';
import 'package:solace/features/payments/data/models/transaction_model.dart';
import 'package:solace/features/payments/data/repositories/payment_repository.dart';
import 'package:solace/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:solace/features/payments/presentation/bloc/payment_event.dart';
import 'package:solace/features/payments/presentation/pages/payment_result_screen.dart';
import 'package:solace/features/payments/presentation/pages/transaction_history_screen.dart';
import 'package:solace/features/therapists/data/models/therapist_model.dart';
import 'package:solace/features/therapists/presentation/pages/therapist_detail_screen.dart';

void main() {
  late AppointmentModel appointment;
  late TherapistModel therapist;
  late TransactionModel transaction;

  setUp(() {
    appointment = AppointmentModel(
      id: 'appointment-1',
      userId: 'user-1',
      therapistId: 'therapist-1',
      dateTime: DateTime(2026, 8, 4, 10, 30),
      sessionType: SessionType.individual,
      status: AppointmentStatus.confirmed,
      amount: 35000,
      notes: 'First session',
      createdAt: DateTime(2026, 7, 30),
      updatedAt: DateTime(2026, 7, 30),
    );
    therapist = const TherapistModel(
      id: 'therapist-1',
      name: 'Dr. Aline Mutoni',
      title: 'Clinical Psychologist',
      specialties: ['Trauma', 'Anxiety'],
      languages: ['Kinyarwanda', 'English'],
      rate: 35000,
      bio: 'Trauma-informed support for adults and families.',
      photoUrl: '',
      rating: 4.9,
      reviewCount: 48,
      location: 'Kigali, Rwanda',
      gender: 'Female',
      availability: [],
    );
    transaction = TransactionModel(
      id: 'transaction-1',
      transactionId: 'SOL-123',
      userId: 'user-1',
      amount: 35000,
      network: PaymentNetwork.mtn,
      status: TransactionStatus.successful,
      timestamp: DateTime(2026, 7, 31, 8),
      appointmentId: appointment.id,
    );
  });

  testWidgets('professional details stay usable on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var booked = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: TherapistDetailScreen(
          therapist: therapist,
          onBook: () => booked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dr. Aline Mutoni'), findsOneWidget);
    expect(find.text('Book Session'), findsOneWidget);
    await tester.tap(find.text('Book Session'));
    expect(booked, isTrue);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(find.text('Book Consultation'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'landscape profile layout');
  });

  testWidgets('reservation confirmation summarizes the selected session', (
    tester,
  ) async {
    final bloc = AppointmentBloc(
      AppointmentRepository(firestore: FakeFirebaseFirestore()),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light,
          home: AppointmentConfirmationScreen(
            appointment: appointment.copyWith(
              status: AppointmentStatus.pendingPayment,
            ),
            therapistName: therapist.name,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your slot is reserved'), findsOneWidget);
    expect(find.text('Dr. Aline Mutoni'), findsOneWidget);
    expect(find.text('Complete payment to confirm your private session.'),
        findsOneWidget);
    expect(find.text('View My Appointments'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appointments list opens a complete appointment detail', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    await firestore
        .collection('therapists')
        .doc(therapist.id)
        .set(therapist.toMap());
    await firestore
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toMap());
    final bloc = AppointmentBloc(
      AppointmentRepository(firestore: firestore),
    )..add(const AppointmentsRequested('user-1'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MyAppointmentsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Appointments'), findsOneWidget);
    expect(find.text('Dr. Aline Mutoni'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    await tester.tap(find.text('Dr. Aline Mutoni'));
    await tester.pumpAndSettle();

    expect(find.text('Appointment Details'), findsOneWidget);
    expect(find.text('35,000 RWF'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);
    expect(find.text('Cancel Appointment'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appointments screen explains an empty schedule', (tester) async {
    final bloc = AppointmentBloc(
      AppointmentRepository(firestore: FakeFirebaseFirestore()),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MyAppointmentsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No upcoming sessions'), findsOneWidget);
    expect(
        find.text('Book a professional when you feel ready.'), findsOneWidget);
  });

  testWidgets('transaction history displays persisted payment activity', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    await firestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
    final bloc = PaymentBloc(PaymentRepository(firestore: firestore))
      ..add(const TransactionsRequested('user-1'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TransactionHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wallet Activity'), findsOneWidget);
    expect(find.text('35,000 RWF'), findsNWidgets(2));
    expect(find.text('Successful'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful payment result links to owned records', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final appointmentBloc = AppointmentBloc(
      AppointmentRepository(firestore: firestore),
    );
    final paymentBloc = PaymentBloc(
      PaymentRepository(firestore: firestore),
    );
    addTearDown(appointmentBloc.close);
    addTearDown(paymentBloc.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appointmentBloc),
          BlocProvider.value(value: paymentBloc),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PaymentResultScreen(
            transaction: transaction,
            appointment: appointment,
            therapistName: therapist.name,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Payment successful'), findsOneWidget);
    expect(find.text('SOL-123'), findsOneWidget);
    expect(find.text('View My Appointments'), findsOneWidget);
    expect(find.text('Transaction History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed payment result offers a clear retry action', (
    tester,
  ) async {
    final paymentBloc = PaymentBloc(
      PaymentRepository(firestore: FakeFirebaseFirestore()),
    );
    addTearDown(paymentBloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: paymentBloc,
        child: MaterialApp(
          theme: AppTheme.light,
          home: PaymentResultScreen(
            transaction: transaction.copyWith(
              status: TransactionStatus.failed,
            ),
            appointment: appointment,
            therapistName: therapist.name,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Payment unsuccessful'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(
        find.text(
            'No charge was completed. Review your details and try again.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
