import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/theme/app_theme.dart';
import 'package:solace/features/appointments/data/models/appointment_model.dart';
import 'package:solace/features/appointments/data/repositories/appointment_repository.dart';
import 'package:solace/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:solace/features/payments/data/repositories/payment_repository.dart';
import 'package:solace/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:solace/features/payments/presentation/pages/payment_checkout_screen.dart';
import 'package:solace/features/therapists/data/models/therapist_model.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  testWidgets('validates checkout details and switches payment network', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final paymentBloc = PaymentBloc(MockPaymentRepository());
    final appointmentBloc = AppointmentBloc(MockAppointmentRepository());
    addTearDown(paymentBloc.close);
    addTearDown(appointmentBloc.close);

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
    const therapist = TherapistModel(
      id: 'therapist-1',
      name: 'Dr. Aline Mutoni',
      title: 'Clinical Psychologist',
      specialties: ['Trauma'],
      languages: ['Kinyarwanda', 'English'],
      rate: 35000,
      bio: 'Trauma-informed support.',
      photoUrl: '',
      rating: 4.9,
      reviewCount: 48,
      location: 'Kigali, Rwanda',
      gender: 'Female',
      availability: [],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: paymentBloc),
          BlocProvider.value(value: appointmentBloc),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PaymentCheckoutScreen(
            appointment: appointment,
            therapist: therapist,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Therapy Checkout'), findsOneWidget);
    expect(find.text('RWF 35,000'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'initial checkout layout');
    var payButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Pay with MoMo'),
    );
    expect(payButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), '0780000000');
    await tester.enterText(find.byType(TextField).at(1), '12345');
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'completed checkout fields');

    payButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Pay with MoMo'),
    );
    expect(payButton.onPressed, isNotNull);

    await tester.tap(find.text('Airtel Money'));
    await tester.pump();
    expect(find.text('Pay with MoMo'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Airtel checkout layout');

    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(find.text('Therapy Checkout'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'landscape checkout layout');
  });
}
