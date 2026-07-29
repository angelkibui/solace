import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failure.dart';
import '../../../../core/utils/result.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection('appointments');

  Future<Result<AppointmentModel>> createAppointment(
    AppointmentModel appointment,
  ) async {
    try {
      final reference = await _appointments.add(appointment.toMap());
      return Success(appointment.copyWith(id: reference.id));
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not book this appointment.'),
      );
    }
  }

  Future<Result<List<AppointmentModel>>> getAppointments(String userId) async {
    try {
      final snapshot =
          await _appointments.where('userId', isEqualTo: userId).get();
      final appointments = snapshot.docs
          .map(AppointmentModel.fromFirestore)
          .toList()
        ..sort((left, right) => left.dateTime.compareTo(right.dateTime));
      return Success(appointments);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not load your appointments.'),
      );
    }
  }

  Future<Result<Map<String, String>>> getTherapistNames(
    Iterable<String> therapistIds,
  ) async {
    try {
      final ids = therapistIds.where((id) => id.isNotEmpty).toSet().toList();
      final names = <String, String>{};
      for (var offset = 0; offset < ids.length; offset += 10) {
        final end = (offset + 10).clamp(0, ids.length);
        final chunk = ids.sublist(offset, end);
        final snapshot = await _firestore
            .collection('therapists')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final document in snapshot.docs) {
          names[document.id] =
              document.data()['name'] as String? ?? 'Solace Professional';
        }
      }
      return Success(names);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not load professional details.'),
      );
    }
  }

  Future<Result<AppointmentModel>> rescheduleAppointment(
    AppointmentModel appointment,
    DateTime dateTime,
  ) async {
    final updated =
        appointment.copyWith(dateTime: dateTime, updatedAt: DateTime.now());
    try {
      await _appointments.doc(appointment.id).update({
        'dateTime': Timestamp.fromDate(dateTime),
        'updatedAt': Timestamp.fromDate(updated.updatedAt),
      });
      return Success(updated);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(
            error.message ?? 'Could not reschedule this appointment.'),
      );
    }
  }

  Future<Result<AppointmentModel>> updateStatus(
    AppointmentModel appointment,
    AppointmentStatus status,
  ) async {
    final updated =
        appointment.copyWith(status: status, updatedAt: DateTime.now());
    try {
      await _appointments.doc(appointment.id).update({
        'status': status.value,
        'updatedAt': Timestamp.fromDate(updated.updatedAt),
      });
      return Success(updated);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not update this appointment.'),
      );
    }
  }

  Future<Result<void>> deleteAppointment(String id) async {
    try {
      await _appointments.doc(id).delete();
      return const Success(null);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not remove this appointment.'),
      );
    }
  }
}
