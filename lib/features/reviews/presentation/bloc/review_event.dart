import 'package:equatable/equatable.dart';

import '../../data/models/review_model.dart';

sealed class ReviewEvent extends Equatable {
	const ReviewEvent();

	@override
	List<Object?> get props => [];
}

class ReviewsRequested extends ReviewEvent {
	final String therapistId;

	const ReviewsRequested(this.therapistId);

	@override
	List<Object?> get props => [therapistId];
}

class ReviewsUpdated extends ReviewEvent {
	final List<ReviewModel> reviews;

	const ReviewsUpdated(this.reviews);

	@override
	List<Object?> get props => [reviews];
}

class ReviewsStreamFailed extends ReviewEvent {
	const ReviewsStreamFailed();
}

class SubmitReviewRequested extends ReviewEvent {
	final String therapistId;
	final String clientId;
	final String clientName;
	final int rating;
	final String title;
	final String content;

	const SubmitReviewRequested({
		required this.therapistId,
		required this.clientId,
		required this.clientName,
		required this.rating,
		required this.title,
		required this.content,
	});

	@override
	List<Object?> get props => [therapistId, clientId, clientName, rating, title, content];
}

class DeleteReviewRequested extends ReviewEvent {
	final String reviewId;
	final String therapistId;

	const DeleteReviewRequested(this.reviewId, this.therapistId);

	@override
	List<Object?> get props => [reviewId, therapistId];
}

class UpdateReviewRequested extends ReviewEvent {
	final String reviewId;
	final int rating;
	final String title;
	final String content;
	final String therapistId;

	const UpdateReviewRequested({
		required this.reviewId,
		required this.rating,
		required this.title,
		required this.content,
		required this.therapistId,
	});

	@override
	List<Object?> get props => [reviewId, rating, title, content, therapistId];
}

class RatingStatsRequested extends ReviewEvent {
	final String therapistId;

	const RatingStatsRequested(this.therapistId);

	@override
	List<Object?> get props => [therapistId];
}

class CanReviewRequested extends ReviewEvent {
	final String clientId;
	final String therapistId;

	const CanReviewRequested(this.clientId, this.therapistId);

	@override
	List<Object?> get props => [clientId, therapistId];
}

class UserReviewRequested extends ReviewEvent {
	final String clientId;
	final String therapistId;

	const UserReviewRequested(this.clientId, this.therapistId);

	@override
	List<Object?> get props => [clientId, therapistId];
}

