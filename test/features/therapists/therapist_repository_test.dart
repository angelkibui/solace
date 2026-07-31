import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/therapists/data/models/therapist_model.dart';
import 'package:solace/features/therapists/data/repositories/therapist_repository.dart';

void main() {
  test('creates, reads, updates, lists, and deletes therapists', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = TherapistRepository(firestore: firestore);
    final therapist = TherapistModel(
      id: '',
      name: 'Dr. Aline Mutoni',
      title: 'Clinical Psychologist',
      specialties: const ['Trauma', 'Anxiety'],
      languages: const ['Kinyarwanda', 'English'],
      rate: 35000,
      bio: 'Trauma-informed support.',
      photoUrl: '',
      rating: 4.9,
      reviewCount: 48,
      location: 'Kigali, Rwanda',
      gender: 'Female',
      availability: [DateTime.utc(2026, 8, 3, 8)],
    );

    final createdId = (await repository.createTherapist(therapist)).dataOrNull;
    expect(createdId, isNotNull);

    final created = (await repository.getTherapist(createdId!)).dataOrNull;
    expect(created?.name, 'Dr. Aline Mutoni');
    expect(
      created?.availability.single.toUtc(),
      DateTime.utc(2026, 8, 3, 8),
    );

    final updated = created!.copyWith(rate: 40000, rating: 5);
    expect((await repository.updateTherapist(updated)).isSuccess, isTrue);
    final loaded = (await repository.getTherapists()).dataOrNull;
    expect(loaded, hasLength(1));
    expect(loaded!.single.rate, 40000);
    expect(loaded.single.rating, 5);

    expect((await repository.deleteTherapist(createdId)).isSuccess, isTrue);
    final missing = await repository.getTherapist(createdId);
    expect(missing.isFailure, isTrue);
  });
}
