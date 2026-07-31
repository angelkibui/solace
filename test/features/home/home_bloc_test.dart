import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solace/features/home/presentation/bloc/home_bloc.dart';
import 'package:solace/features/home/presentation/bloc/home_event.dart';
import 'package:solace/features/home/presentation/bloc/home_state.dart';

void main() {
  group('HomeBloc', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded(isPersonalized: false)] when the user has no preferences',
      build: () => HomeBloc(userConcerns: const []),
      act: (bloc) => bloc.add(const HomeStarted()),
      wait: const Duration(milliseconds: 800),
      expect: () => [
        const HomeLoading(),
        isA<HomeLoaded>()
            .having((s) => s.isPersonalized, 'isPersonalized', false),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'ranks a matching therapist first when the user has selected that concern',
      build: () => HomeBloc(userConcerns: const ['Recovery Challenges']),
      act: (bloc) => bloc.add(const HomeStarted()),
      wait: const Duration(milliseconds: 800),
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<HomeLoaded>());
        final loaded = state as HomeLoaded;
        expect(loaded.isPersonalized, isTrue);
        // Eric Habimana is the only mock therapist tagged with
        // 'Recovery Challenges' — he should be ranked first.
        expect(loaded.recommendedTherapists.first.name, 'Eric Habimana');
      },
    );

    blocTest<HomeBloc, HomeState>(
      'HomeRefreshRequested reloads the same way HomeStarted does',
      build: () => HomeBloc(userConcerns: const []),
      act: (bloc) => bloc.add(const HomeRefreshRequested()),
      wait: const Duration(milliseconds: 800),
      expect: () => [
        const HomeLoading(),
        isA<HomeLoaded>(),
      ],
    );
  });
}
