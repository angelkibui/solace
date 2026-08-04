import 'package:equatable/equatable.dart';

import '../../data/models/review_model.dart';

enum ReviewStatus { initial, loading, loaded, submitting, failure }

class ReviewState extends Equatable {
	final ReviewStatus status;
	final List<ReviewModel> reviews;
	final double averageRating;
	final int totalReviews;
	final Map<int, int> ratingDistribution;
	final bool canReview;
	final ReviewModel? userReview;
	final bool isSubmitting;
	final String? errorMessage;

	const ReviewState({
		this.status = ReviewStatus.initial,
		this.reviews = const [],
		this.averageRating = 0.0,
		this.totalReviews = 0,
		this.ratingDistribution = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
		this.canReview = false,
		this.userReview,
		this.isSubmitting = false,
		this.errorMessage,
	});

	ReviewState copyWith({
		ReviewStatus? status,
		List<ReviewModel>? reviews,
		double? averageRating,
		int? totalReviews,
		Map<int, int>? ratingDistribution,
		bool? canReview,
		ReviewModel? userReview,
		bool? isSubmitting,
		String? errorMessage,
		bool clearError = false,
	}) {
		return ReviewState(
			status: status ?? this.status,
			reviews: reviews ?? this.reviews,
			averageRating: averageRating ?? this.averageRating,
			totalReviews: totalReviews ?? this.totalReviews,
			ratingDistribution: ratingDistribution ?? this.ratingDistribution,
			canReview: canReview ?? this.canReview,
			userReview: userReview ?? this.userReview,
			isSubmitting: isSubmitting ?? this.isSubmitting,
			errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
		);
	}

	@override
	List<Object?> get props => [
				status,
				reviews,
				averageRating,
				totalReviews,
				ratingDistribution,
				canReview,
				userReview,
				isSubmitting,
				errorMessage,
			];
}

