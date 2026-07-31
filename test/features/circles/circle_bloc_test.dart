import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/utils/failure.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/circles/data/models/circle_model.dart';
import 'package:solace/features/circles/data/repositories/circle_repository.dart';
import 'package:solace/features/circles/presentation/bloc/circle_bloc.dart';
import 'package:solace/features/circles/presentation/bloc/circle_event.dart';
import 'package:solace/features/circles/presentation/bloc/circle_state.dart';

class MockCircleRepository extends Mock implements CircleRepository {}

void main() {
  late MockCircleRepository repository;

  final sobriety = CircleModel(
    id: 'sobriety-circle',
    name: 'Sobriety Circle',
    description: 'Recovery, one day at a time.',
    category: 'Recovery Networks',
    memberCount: 214,
    isModerated: true,
    moderatorName: 'Eric Mugisha',
    createdAt: DateTime(2026, 1, 1),
    imageUrl: '',
    memberIds: const [],
  );

  final anxiety = CircleModel(
    id: 'anxiety-support',
    name: 'Anxiety Support',
    description: 'Coping strategies, together.',
    category: 'Anxiety Support',
    memberCount: 356,
    isModerated: true,
    moderatorName: 'Diane Uwase',
    createdAt: DateTime(2026, 1, 1),
    imageUrl: '',
    memberIds: const ['uid-1'],
  );

  setUp(() {
    repository = MockCircleRepository();
  });

  group('CirclesRequested', () {
    blocTest<CircleBloc, CircleState>(
      'emits [loading, success] with circles on successful load',
      setUp: () {
        when(() => repository.getCircles())
            .thenAnswer((_) async => Success([sobriety, anxiety]));
      },
      build: () => CircleBloc(repository, userId: 'uid-1'),
      act: (bloc) => bloc.add(const CirclesRequested()),
      expect: () => [
        isA<CircleState>().having((s) => s.status, 'status', CircleStatus.loading),
        isA<CircleState>()
            .having((s) => s.status, 'status', CircleStatus.success)
            .having((s) => s.circles.length, 'circles.length', 2),
      ],
    );

    blocTest<CircleBloc, CircleState>(
      'emits [loading, failure] when the repository call fails',
      setUp: () {
        when(() => repository.getCircles())
            .thenAnswer((_) async => const ResultError(ServerFailure('Network error.')));
      },
      build: () => CircleBloc(repository, userId: 'uid-1'),
      act: (bloc) => bloc.add(const CirclesRequested()),
      expect: () => [
        isA<CircleState>().having((s) => s.status, 'status', CircleStatus.loading),
        isA<CircleState>()
            .having((s) => s.status, 'status', CircleStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Network error.'),
      ],
    );
  });

  group('CircleJoinToggled', () {
    blocTest<CircleBloc, CircleState>(
      'joining adds the uid and increments memberCount',
      setUp: () {
        when(() => repository.getCircles())
            .thenAnswer((_) async => Success([sobriety]));
        when(() => repository.joinCircle('sobriety-circle', 'uid-1'))
            .thenAnswer((_) async => const Success(null));
      },
      build: () => CircleBloc(repository, userId: 'uid-1'),
      act: (bloc) async {
        bloc.add(const CirclesRequested());
        await bloc.stream.firstWhere((s) => s.status == CircleStatus.success);
        bloc.add(const CircleJoinToggled('sobriety-circle'));
      },
      verify: (bloc) {
        final circle = bloc.state.circles.first;
        expect(circle.memberIds, contains('uid-1'));
        expect(circle.memberCount, 215);
        expect(bloc.state.pendingCircleIds, isEmpty);
      },
    );

    blocTest<CircleBloc, CircleState>(
      'leaving removes the uid and decrements memberCount',
      setUp: () {
        when(() => repository.getCircles())
            .thenAnswer((_) async => Success([anxiety]));
        when(() => repository.leaveCircle('anxiety-support', 'uid-1'))
            .thenAnswer((_) async => const Success(null));
      },
      build: () => CircleBloc(repository, userId: 'uid-1'),
      act: (bloc) async {
        bloc.add(const CirclesRequested());
        await bloc.stream.firstWhere((s) => s.status == CircleStatus.success);
        bloc.add(const CircleJoinToggled('anxiety-support'));
      },
      verify: (bloc) {
        final circle = bloc.state.circles.first;
        expect(circle.memberIds, isNot(contains('uid-1')));
        expect(circle.memberCount, 355);
      },
    );
  });

  group('CircleState.visibleCircles', () {
    test('filters by category', () {
      final state = CircleState(
        userId: 'uid-1',
        circles: [sobriety, anxiety],
        category: 'Anxiety Support',
      );
      expect(state.visibleCircles, [anxiety]);
    });

    test('myCirclesOnly shows only circles the user has joined', () {
      final state = CircleState(
        userId: 'uid-1',
        circles: [sobriety, anxiety],
        myCirclesOnly: true,
      );
      // Only `anxiety` includes 'uid-1' in memberIds.
      expect(state.visibleCircles, [anxiety]);
    });
  });
}
