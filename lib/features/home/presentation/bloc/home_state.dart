import 'package:equatable/equatable.dart';


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
