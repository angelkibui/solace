import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/theme/app_theme.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/therapists/data/models/therapist_model.dart';
import 'package:solace/features/therapists/data/repositories/therapist_repository.dart';
import 'package:solace/features/therapists/presentation/bloc/therapist_bloc.dart';
import 'package:solace/features/therapists/presentation/bloc/therapist_event.dart';
import 'package:solace/features/therapists/presentation/pages/therapist_list_screen.dart';

class MockTherapistRepository extends Mock implements TherapistRepository {}

void main() {
  testWidgets('displays and searches loaded professionals', (tester) async {
    final repository = MockTherapistRepository();
    final therapists = [
      TherapistModel(
        id: 'aline',
        name: 'Dr. Aline Mutoni',
        title: 'Clinical Psychologist',
        specialties: const ['Trauma', 'Anxiety'],
        languages: const ['Kinyarwanda', 'English'],
        rate: 35000,
        bio: 'Trauma-informed support in Kigali.',
        photoUrl: '',
        rating: 4.9,
        reviewCount: 48,
        location: 'Kigali, Rwanda',
        gender: 'Female',
        availability: [DateTime(2026, 8, 1, 9)],
      ),
      TherapistModel(
        id: 'jean-luc',
        name: 'Jean-Luc Nshimiye',
        title: 'Licensed Counselor',
        specialties: const ['Grief Support'],
        languages: const ['English', 'French'],
        rate: 28000,
        bio: 'Support through life transitions.',
        photoUrl: '',
        rating: 4.7,
        reviewCount: 31,
        location: 'Huye, Rwanda',
        gender: 'Male',
        availability: [DateTime(2026, 8, 2, 14)],
      ),
    ];
    when(repository.getTherapists).thenAnswer((_) async => Success(therapists));

    final bloc = TherapistBloc(repository)..add(const TherapistsRequested());
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TherapistListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dr. Aline Mutoni'), findsOneWidget);
    expect(find.text('Jean-Luc Nshimiye'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Aline');
    await tester.pump();

    expect(find.text('Dr. Aline Mutoni'), findsOneWidget);
    expect(find.text('Jean-Luc Nshimiye'), findsNothing);
  });
}
