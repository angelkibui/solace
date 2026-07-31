import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failure.dart';
import '../../../../core/utils/result.dart';
import '../models/circle_model.dart';

class CircleRepository {
  final FirebaseFirestore _firestore;

  CircleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('circles');

  Future<Result<List<CircleModel>>> getCircles() async {
    try {
      final snapshot =
          await _collection.orderBy('memberCount', descending: true).get();
      return Success(snapshot.docs.map(CircleModel.fromFirestore).toList());
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not load circles.'),
      );
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  Future<Result<CircleModel>> getCircle(String id) async {
    try {
      final document = await _collection.doc(id).get();
      if (!document.exists) {
        return const ResultError(ServerFailure('Circle not found.'));
      }
      return Success(CircleModel.fromFirestore(document));
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not load this circle.'),
      );
    }
  }

  Future<Result<String>> createCircle(CircleModel circle) async {
    try {
      final reference = await _collection.add(circle.toMap());
      return Success(reference.id);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not create this circle.'),
      );
    }
  }

  Future<Result<void>> joinCircle(String circleId, String userId) async {
    try {
      await _collection.doc(circleId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
      });
      return const Success(null);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not join this circle.'),
      );
    }
  }

  Future<Result<void>> leaveCircle(String circleId, String userId) async {
    try {
      await _collection.doc(circleId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'memberCount': FieldValue.increment(-1),
      });
      return const Success(null);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not leave this circle.'),
      );
    }
  }
}
