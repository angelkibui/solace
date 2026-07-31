import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/circles/data/models/circle_model.dart';
import 'package:solace/features/circles/data/repositories/circle_repository.dart';

void main() {
  test('persists the circle CRUD and membership lifecycle', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = CircleRepository(firestore: firestore);
    final circle = CircleModel(
      id: '',
      name: 'Anxiety Support',
      description: 'A moderated support space.',
      category: 'Anxiety Support',
      memberCount: 10,
      isModerated: true,
      moderatorName: 'Diane Uwase',
      createdAt: DateTime.utc(2026, 7, 31),
      imageUrl: '',
    );

    final createdId = (await repository.createCircle(circle)).dataOrNull;
    expect(createdId, isNotNull);

    final created = (await repository.getCircle(createdId!)).dataOrNull;
    expect(created?.name, 'Anxiety Support');

    final updated = created!.copyWith(name: 'Calm Together');
    expect((await repository.updateCircle(updated)).isSuccess, isTrue);
    expect(
      (await repository.getCircles()).dataOrNull?.single.name,
      'Calm Together',
    );

    expect(
      (await repository.joinCircle(createdId, 'user-1')).isSuccess,
      isTrue,
    );
    var membership = (await repository.getCircle(createdId)).dataOrNull!;
    expect(membership.memberIds, ['user-1']);
    expect(membership.memberCount, 11);

    expect(
      (await repository.leaveCircle(createdId, 'user-1')).isSuccess,
      isTrue,
    );
    membership = (await repository.getCircle(createdId)).dataOrNull!;
    expect(membership.memberIds, isEmpty);
    expect(membership.memberCount, 10);

    expect((await repository.deleteCircle(createdId)).isSuccess, isTrue);
    expect((await repository.getCircle(createdId)).isFailure, isTrue);
  });

  test('rejects update and delete requests without a circle ID', () async {
    final repository = CircleRepository(firestore: FakeFirebaseFirestore());
    final circle = CircleModel(
      id: '',
      name: 'Circle',
      description: 'Description',
      category: 'General',
      memberCount: 0,
      isModerated: true,
      moderatorName: 'Moderator',
      createdAt: DateTime.utc(2026),
      imageUrl: '',
    );

    expect((await repository.updateCircle(circle)).isFailure, isTrue);
    expect((await repository.deleteCircle('')).isFailure, isTrue);
  });
}
