import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
	final ReviewRepository _repository;
	StreamSubscription<List<ReviewModel>>? _reviewsSub;

	ReviewBloc(this._repository) : super(const ReviewState()) {
		on<ReviewsRequested>(_onReviewsRequested);
		on<ReviewsUpdated>(_onReviewsUpdated);
		on<ReviewsStreamFailed>(_onReviewsStreamFailed);
		on<SubmitReviewRequested>(_onSubmitReviewRequested);
		on<DeleteReviewRequested>(_onDeleteReviewRequested);
		on<UpdateReviewRequested>(_onUpdateReviewRequested);
		on<RatingStatsRequested>(_onRatingStatsRequested);
		on<CanReviewRequested>(_onCanReviewRequested);
		on<UserReviewRequested>(_onUserReviewRequested);
	}

	Future<void> _onReviewsRequested(
		ReviewsRequested event,
		Emitter<ReviewState> emit,
	) async {
		await _reviewsSub?.cancel();
		emit(state.copyWith(status: ReviewStatus.loading, clearError: true));

		_reviewsSub = _repository
				.getTherapistReviews(event.therapistId)
				.listen((reviews) => add(ReviewsUpdated(reviews)), onError: (_, __) {
			add(const ReviewsStreamFailed());
		});

		// Also request the stats and user's existing review
		add(RatingStatsRequested(event.therapistId));
	}

	void _onReviewsUpdated(ReviewsUpdated event, Emitter<ReviewState> emit) {
		emit(state.copyWith(status: ReviewStatus.loaded, reviews: event.reviews));
	}

	void _onReviewsStreamFailed(
		ReviewsStreamFailed event,
		Emitter<ReviewState> emit,
	) {
		emit(state.copyWith(
			status: ReviewStatus.failure,
			errorMessage: 'Could not load reviews. Check your connection.',
		));
	}

	Future<void> _onSubmitReviewRequested(
		SubmitReviewRequested event,
		Emitter<ReviewState> emit,
	) async {
		final current = state;
		if (event.rating < 1 || event.rating > 5) return;

		emit(current.copyWith(isSubmitting: true, clearError: true));

		final review = ReviewModel(
			id: '',
			therapistId: event.therapistId,
			clientId: event.clientId,
			clientName: event.clientName,
			rating: event.rating,
			title: event.title,
			content: event.content,
			createdAt: DateTime.now(),
		);

		final result = await _repository.submitReview(review: review);
		result.fold(
			(failure) => emit(current.copyWith(
					isSubmitting: false, errorMessage: failure.message)),
			(_) async {
				emit(current.copyWith(isSubmitting: false, clearError: true));
				// refresh stats (stream will deliver new review automatically)
				add(RatingStatsRequested(event.therapistId));
			},
		);
	}

	Future<void> _onDeleteReviewRequested(
		DeleteReviewRequested event,
		Emitter<ReviewState> emit,
	) async {
		final current = state;
		emit(current.copyWith(isSubmitting: true, clearError: true));
		final result = await _repository.deleteReview(
			reviewId: event.reviewId,
			therapistId: event.therapistId,
		);
		result.fold(
			(failure) => emit(current.copyWith(
					isSubmitting: false, errorMessage: failure.message)),
			(_) => emit(current.copyWith(isSubmitting: false, clearError: true)),
		);
		add(RatingStatsRequested(event.therapistId));
	}

	Future<void> _onUpdateReviewRequested(
		UpdateReviewRequested event,
		Emitter<ReviewState> emit,
	) async {
		final current = state;
		emit(current.copyWith(isSubmitting: true, clearError: true));
		final updated = ReviewModel(
			id: event.reviewId,
			therapistId: event.therapistId,
			clientId: current.userReview?.clientId ?? '',
			clientName: current.userReview?.clientName ?? '',
			rating: event.rating,
			title: event.title,
			content: event.content,
			createdAt: current.userReview?.createdAt ?? DateTime.now(),
		);

		final result = await _repository.updateReview(
			reviewId: event.reviewId,
			updatedReview: updated,
			therapistId: event.therapistId,
		);

		result.fold(
			(failure) => emit(current.copyWith(
					isSubmitting: false, errorMessage: failure.message)),
			(_) => emit(current.copyWith(isSubmitting: false, clearError: true)),
		);

		add(RatingStatsRequested(event.therapistId));
	}

	Future<void> _onRatingStatsRequested(
		RatingStatsRequested event,
		Emitter<ReviewState> emit,
	) async {
		final current = state;
		final result = await _repository.getTherapistRatingStats(event.therapistId);
		result.fold(
			(failure) => emit(current.copyWith(errorMessage: failure.message)),
			(data) => emit(current.copyWith(
						averageRating: (data['averageRating'] as double?) ?? 0.0,
						totalReviews: (data['totalReviews'] as int?) ?? 0,
						ratingDistribution:
								(data['ratingDistribution'] as Map<int, int>?) ?? current.ratingDistribution,
						clearError: true,
					)),
		);
	}

	Future<void> _onCanReviewRequested(
		CanReviewRequested event,
		Emitter<ReviewState> emit,
	) async {
		final current = state;
		final result = await _repository.canReview(
			clientId: event.clientId,
			therapistId: event.therapistId,
		);
		result.fold(
			(failure) => emit(current.copyWith(errorMessage: failure.message)),
			(allowed) => emit(current.copyWith(canReview: allowed, clearError: true)),
		);
	}

	Future<void> _onUserReviewRequested(
		UserReviewRequested event,
		Emitter<ReviewState> emit,
	) async {
		final current = state;
		final result = await _repository.getUserReview(
			clientId: event.clientId,
			therapistId: event.therapistId,
		);
		result.fold(
			(failure) => emit(current.copyWith(errorMessage: failure.message)),
			(review) => emit(current.copyWith(userReview: review, clearError: true)),
		);
	}

	@override
	Future<void> close() async {
		await _reviewsSub?.cancel();
		return super.close();
	}
}

