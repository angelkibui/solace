import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/failure.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');

  CollectionReference<Map<String, dynamic>> get _therapists =>
      _firestore.collection('therapists');

  /// Submit a review for a therapist
  Future<Result<void>> submitReview({
    required ReviewModel review,
  }) async {
    if (review.rating < 1 || review.rating > 5) {
      return const ResultError(
        ServerFailure('Rating must be between 1 and 5'),
      );
    }

    if (review.title.isEmpty || review.title.trim().isEmpty) {
      return const ResultError(
        ServerFailure('Review title cannot be empty'),
      );
    }

    if (review.content.isEmpty || review.content.trim().isEmpty) {
      return const ResultError(
        ServerFailure('Review content cannot be empty'),
      );
    }

    if (review.title.length > 100) {
      return const ResultError(
        ServerFailure('Title must be less than 100 characters'),
      );
    }

    if (review.content.length > 1000) {
      return const ResultError(
        ServerFailure('Content must be less than 1000 characters'),
      );
    }

    try {
      // Check if user already reviewed this therapist
      final existing = await _reviews
          .where('therapistId', isEqualTo: review.therapistId)
          .where('clientId', isEqualTo: review.clientId)
          .get();

      if (existing.docs.isNotEmpty) {
        return const ResultError(
          ServerFailure('You have already reviewed this therapist'),
        );
      }

      // Add review with server timestamp
      await _reviews.add({
        ...review.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update therapist rating
      await _updateTherapistRating(review.therapistId);

      return const Success(null);
    } on FirebaseException catch (e) {
      return ResultError(ServerFailure(e.message ?? 'Failed to submit review'));
    } catch (e) {
      return ResultError(ServerFailure(e.toString()));
    }
  }

  /// Get reviews for a therapist
  Stream<List<ReviewModel>> getTherapistReviews(String therapistId) {
    return _reviews
        .where('therapistId', isEqualTo: therapistId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromDoc(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  /// Get average rating and count for a therapist
  Future<Result<Map<String, dynamic>>> getTherapistRatingStats(
    String therapistId,
  ) async {
    try {
      final reviews = await _reviews
          .where('therapistId', isEqualTo: therapistId)
          .get();

      if (reviews.docs.isEmpty) {
        return const Success({
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
        });
      }

      final ratings = reviews.docs
          .map((doc) => (doc.data()['rating'] as num?)?.toInt() ?? 0)
          .toList();

      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

      // Calculate rating distribution
      final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var rating in ratings) {
        if (distribution.containsKey(rating)) {
          distribution[rating] = distribution[rating]! + 1;
        }
      }

      return Success({
        'averageRating': averageRating,
        'totalReviews': reviews.docs.length,
        'ratingDistribution': distribution,
      });
    } catch (e) {
      return ResultError(ServerFailure(e.toString()));
    }
  }

  /// Update therapist's average rating in therapist document
  Future<void> _updateTherapistRating(String therapistId) async {
    try {
      final reviews = await _reviews
          .where('therapistId', isEqualTo: therapistId)
          .get();

      if (reviews.docs.isEmpty) {
        await _therapists.doc(therapistId).update({
          'rating': 0,
          'reviewCount': 0,
        });
        return;
      }

      final ratings = reviews.docs
          .map((doc) => (doc.data()['rating'] as num?)?.toDouble() ?? 0)
          .toList();

      final averageRating =
          ratings.reduce((a, b) => a + b) / ratings.length;

      await _therapists.doc(therapistId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
        'reviewCount': reviews.docs.length,
      });
    } catch (e) {
      print('Error updating therapist rating: $e');
    }
  }

  /// Check if user can review (verified session)
  Future<Result<bool>> canReview({
    required String clientId,
    required String therapistId,
  }) async {
    try {
      // Check if client has completed appointment with therapist
      final appointments = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: clientId)
          .where('therapistId', isEqualTo: therapistId)
          .where('status', isEqualTo: 'completed')
          .get();

      return Success(appointments.docs.isNotEmpty);
    } catch (e) {
      return ResultError(ServerFailure(e.toString()));
    }
  }

  /// Delete review (by author)
  Future<Result<void>> deleteReview({
    required String reviewId,
    required String therapistId,
  }) async {
    try {
      await _reviews.doc(reviewId).delete();
      await _updateTherapistRating(therapistId);
      return const Success(null);
    } on FirebaseException catch (e) {
      return ResultError(ServerFailure(e.message ?? 'Failed to delete review'));
    } catch (e) {
      return ResultError(ServerFailure(e.toString()));
    }
  }

  /// Update review
  Future<Result<void>> updateReview({
    required String reviewId,
    required ReviewModel updatedReview,
    required String therapistId,
  }) async {
    if (updatedReview.rating < 1 || updatedReview.rating > 5) {
      return const ResultError(
        ServerFailure('Rating must be between 1 and 5'),
      );
    }

    try {
      await _reviews.doc(reviewId).update({
        'rating': updatedReview.rating,
        'title': updatedReview.title,
        'content': updatedReview.content,
      });
      await _updateTherapistRating(therapistId);
      return const Success(null);
    } on FirebaseException catch (e) {
      return ResultError(ServerFailure(e.message ?? 'Failed to update review'));
    } catch (e) {
      return ResultError(ServerFailure(e.toString()));
    }
  }

  /// Get user's review for a therapist
  Future<Result<ReviewModel?>> getUserReview({
    required String clientId,
    required String therapistId,
  }) async {
    try {
      final query = await _reviews
          .where('therapistId', isEqualTo: therapistId)
          .where('clientId', isEqualTo: clientId)
          .get();

      if (query.docs.isEmpty) {
        return const Success(null);
      }

      return Success(ReviewModel.fromDoc(
        query.docs.first as DocumentSnapshot<Map<String, dynamic>>,
      ));
    } catch (e) {
      return ResultError(ServerFailure(e.toString()));
    }
  }
}