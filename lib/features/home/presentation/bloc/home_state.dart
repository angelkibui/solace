import 'package:equatable/equatable.dart';

/// Stand-in for a real TherapistModel (Part F hasn't been built yet).
/// [concernTags] drives the personalization in HomeBloc — matched against
/// the signed-in user's UserModel.preferences.
typedef RecommendedTherapist = ({
  String name,
  String roleLabel,
  List<String> concernTags,
  String bio,
  List<String> languages,
  String rate,
  double rating,
  int reviewCount,
});

/// Stand-in for a real CircleModel (Part I hasn't been built yet).
typedef TrendingCircle = ({
  String title,
  String description,
  int memberCount,
});

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<RecommendedTherapist> recommendedTherapists;
  final List<TrendingCircle> trendingCircles;

  /// True when [recommendedTherapists] was actually filtered/ranked by the
  /// user's selected concerns rather than falling back to the unfiltered
  /// list (e.g. a user who registered before Part C existed, or skipped
  /// concern selection, has no preferences to match against).
  final bool isPersonalized;

  const HomeLoaded({
    required this.recommendedTherapists,
    required this.trendingCircles,
    required this.isPersonalized,
  });

  @override
  List<Object?> get props => [recommendedTherapists, trendingCircles, isPersonalized];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
