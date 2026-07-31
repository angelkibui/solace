import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/utils/failure.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/therapists/data/models/therapist_model.dart';
import 'package:solace/features/therapists/data/repositories/therapist_repository.dart';
import 'package:solace/features/therapists/presentation/bloc/therapist_bloc.dart';
import 'package:solace/features/therapists/presentation/bloc/therapist_event.dart';
import 'package:solace/features/therapists/presentation/bloc/therapist_state.dart';

class MockTherapistRepository extends Mock implements TherapistRepository {}

void main() {
  late MockTherapistRepository repository;

  final therapists = [
    TherapistModel(
      id: 'aline',
      name: 'Dr. Aline Mutoni',
      title: 'Clinical Psychologist',
      specialties: const ['Trauma', 'Anxiety'],
      languages: const ['Kinyarwanda', 'English'],
      rate: 35000,
      bio: 'Trauma-informed care for young adults.',
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
      specialties: const ['Grief Support', 'Work Stress'],
      languages: const ['English', 'French'],
      rate: 28000,
      bio: 'Practical support through life transitions.',
      photoUrl: '',
      rating: 4.7,
      reviewCount: 31,
      location: 'Huye, Rwanda',
      gender: 'Male',
      availability: [DateTime(2026, 8, 2, 14)],
    ),
  ];

  setUp(() {
    repository = MockTherapistRepository();
  });

  blocTest<TherapistBloc, TherapistState>(
    'loads professionals from the repository',
    setUp: () {
      when(repository.getTherapists)
          .thenAnswer((_) async => Success(therapists));
    },
    build: () => TherapistBloc(repository),
    act: (bloc) => bloc.add(const TherapistsRequested()),
    expect: () => [
      const TherapistState(status: TherapistStatus.loading),
      TherapistState(status: TherapistStatus.success, therapists: therapists),
    ],
  );

  blocTest<TherapistBloc, TherapistState>(
    'reports a friendly load failure',
    setUp: () {
      when(repository.getTherapists).thenAnswer(
        (_) async =>
            const ResultError(ServerFailure('Connection unavailable.')),
      );
    },
    build: () => TherapistBloc(repository),
    act: (bloc) => bloc.add(const TherapistsRequested()),
    expect: () => [
      const TherapistState(status: TherapistStatus.loading),
      const TherapistState(
        status: TherapistStatus.failure,
        errorMessage: 'Connection unavailable.',
      ),
    ],
  );

  test('combines search and specialty filters', () {
    final state = TherapistState(
      status: TherapistStatus.success,
      therapists: therapists,
      query: 'aline',
      specialty: 'Anxiety',
    );

    expect(state.visibleTherapists, [therapists.first]);
  });

  test('filters by language, gender, and maximum rate', () {
    final state = TherapistState(
      status: TherapistStatus.success,
      therapists: therapists,
      language: 'French',
      gender: 'Male',
      maximumRate: 30000,
    );

    expect(state.visibleTherapists, [therapists.last]);
  });
}
