import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

/// Drives Home's "Recommended for you" and "Trending Circles" rows.
///
/// There's no TherapistRepository or CircleRepository yet (Parts F and I
/// are unstarted), so this reads from a small hardcoded list — same
/// approach Angel used for the onboarding preview screen. What *is* real
/// here is the personalization logic (E6): recommendations are ranked by
/// how many of [_userConcerns] (the signed-in user's UserModel.preferences,
/// captured at registration — see RegisterRequested.preferences) overlap
/// with each therapist's concern tags. Swap [_mockTherapists] for a
/// TherapistRepository call whenever Part F lands; the ranking logic below
/// doesn't need to change.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final List<String> _userConcerns;

  HomeBloc({required List<String> userConcerns})
      : _userConcerns = userConcerns,
        super(const HomeInitial()) {
    on<HomeStarted>(_onLoad);
    on<HomeRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      // Simulates a network round-trip so LoadingShimmer/RefreshIndicator
      // have something real to show — replace with an actual Firestore
      // read once TherapistRepository/CircleRepository exist.
      await Future.delayed(const Duration(milliseconds: 700));

      final hasPreferences = _userConcerns.isNotEmpty;
      final ranked = [..._mockTherapists]
        ..sort((a, b) => _matchScore(b, _userConcerns).compareTo(_matchScore(a, _userConcerns)));

      emit(HomeLoaded(
        recommendedTherapists: ranked,
        trendingCircles: _mockCircles,
        isPersonalized: hasPreferences,
      ));
    } catch (_) {
      emit(const HomeError('Could not load your recommendations. Pull down to try again.'));
    }
  }

  int _matchScore(RecommendedTherapist therapist, List<String> userConcerns) {
    if (userConcerns.isEmpty) return 0;
    return therapist.concernTags.where(userConcerns.contains).length;
  }

  static const _mockTherapists = <RecommendedTherapist>[
    (
      name: 'Dr. Aline Mutoni',
      roleLabel: 'Clinical Psychologist',
      concernTags: ['Anxiety', 'Grief & Loss', 'Family Conflict'],
      bio: 'Specializing in post-traumatic growth and family dynamics with over 10 years '
          'of experience in Kigali.',
      languages: ['Kinyarwanda', 'English'],
      rate: '35,000 RWF / hr',
      rating: 4.9,
      reviewCount: 128,
    ),
    (
      name: 'Jean-Luc Nshimiye',
      roleLabel: 'Licensed Counselor',
      concernTags: ['Work Stress', 'Anxiety'],
      bio: 'Dedicated to providing a safe, non-judgmental space for individuals '
          'navigating life\'s transitions and workplace stress.',
      languages: ['English', 'French'],
      rate: '28,000 RWF / hr',
      rating: 4.7,
      reviewCount: 64,
    ),
    (
      name: 'Dr. Uwase Keza',
      roleLabel: 'CBT Specialist',
      concernTags: ['Depression', 'Self-Esteem', 'Sleep Issues'],
      bio: 'Cognitive behavioral therapy focused on breaking cycles of negative thought '
          'patterns and rebuilding daily routines.',
      languages: ['Kinyarwanda', 'English'],
      rate: '32,000 RWF / hr',
      rating: 4.8,
      reviewCount: 91,
    ),
    (
      name: 'Eric Habimana',
      roleLabel: 'Addiction Counselor',
      concernTags: ['Recovery Challenges', 'Family Conflict'],
      bio: 'Supports clients through recovery from alcohol and substance use with a '
          'relapse-prevention and peer-support approach.',
      languages: ['Kinyarwanda'],
      rate: '25,000 RWF / hr',
      rating: 4.6,
      reviewCount: 47,
    ),
  ];

  static const _mockCircles = <TrendingCircle>[
    (title: 'Sobriety Circle', description: 'A moderated space for recovery, one day at a time.', memberCount: 214),
    (title: 'Anxiety Support', description: 'Share coping strategies with people who understand.', memberCount: 356),
    (title: 'Young Professionals', description: 'Managing work stress and burnout, together.', memberCount: 189),
  ];
}
