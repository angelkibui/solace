import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failure.dart';
import '../../../../core/utils/result.dart';
import '../models/therapist_model.dart';

class TherapistRepository {
  final FirebaseFirestore _firestore;

  TherapistRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('therapists');

  Future<Result<List<TherapistModel>>> getTherapists() async {
    try {
      final snapshot =
          await _collection.orderBy('rating', descending: true).get();
      return Success(snapshot.docs.map(TherapistModel.fromFirestore).toList());
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not load professionals.'),
      );
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  Future<Result<TherapistModel>> getTherapist(String id) async {
    try {
      final document = await _collection.doc(id).get();
      if (!document.exists) {
        return const ResultError(ServerFailure('Professional not found.'));
      }
      return Success(TherapistModel.fromFirestore(document));
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not load this profile.'),
      );
    }
  }

  Future<Result<String>> createTherapist(TherapistModel therapist) async {
    try {
      final reference = await _collection.add(therapist.toMap());
      return Success(reference.id);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not add this professional.'),
      );
    }
  }

  Future<Result<void>> updateTherapist(TherapistModel therapist) async {
    try {
      await _collection.doc(therapist.id).update(therapist.toMap());
      return const Success(null);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not update this profile.'),
      );
    }
  }

  Future<Result<void>> deleteTherapist(String id) async {
    try {
      await _collection.doc(id).delete();
      return const Success(null);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not remove this profile.'),
      );
    }
  }
}
