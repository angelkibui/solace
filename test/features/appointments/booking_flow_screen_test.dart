import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/theme/app_theme.dart';
import 'package:solace/features/appointments/data/repositories/appointment_repository.dart';
import 'package:solace/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:solace/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:solace/features/appointments/presentation/pages/booking_flow_screen.dart';
import 'package:solace/features/therapists/data/models/therapist_model.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  testWidgets('moves through each booking step without setState',
      (tester) async {
    final bloc = AppointmentBloc(MockAppointmentRepository());
    addTearDown(bloc.close);
    const therapist = TherapistModel(
      id: 'therapist-1',
      name: 'Dr. Aline Mutoni',
      title: 'Clinical Psychologist',
      specialties: ['Trauma', 'Anxiety'],
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
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const BookingFlowScreen(
            userId: 'user-1',
            therapist: therapist,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose a Date'), findsOneWidget);
    bloc.add(BookingDateSelected(DateTime.now().add(const Duration(days: 2))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a Time'), findsOneWidget);
    bloc.add(const BookingTimeSelected(TimeOfDay(hour: 10, minute: 30)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Session Type'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Review Booking'), findsOneWidget);
    expect(find.text('Proceed to Payment'), findsOneWidget);
    expect(find.text('Dr. Aline Mutoni'), findsOneWidget);

    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpAndSettle();
    expect(find.text('Review Booking'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'landscape booking layout');
  });
}
