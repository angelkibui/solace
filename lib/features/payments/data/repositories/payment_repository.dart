import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../models/transaction_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore;

  PaymentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _transactions =>
      _firestore.collection('transactions');

  Future<Result<TransactionModel>> createTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final reference = await _transactions.add(transaction.toMap());
      return Success(transaction.copyWith(id: reference.id));
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not start this payment.'),
      );
    }
  }

  Future<Result<TransactionModel>> completeTransaction(
    TransactionModel transaction,
    TransactionStatus status,
  ) async {
    try {
      final batch = _firestore.batch();
      batch.update(_transactions.doc(transaction.id), {'status': status.value});
      if (status == TransactionStatus.successful) {
        batch.update(
            _firestore
                .collection('appointments')
                .doc(transaction.appointmentId),
            {
              'status': AppointmentStatus.confirmed.value,
              'updatedAt': Timestamp.now(),
            });
      }
      await batch.commit();
      return Success(transaction.copyWith(status: status));
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not complete this payment.'),
      );
    }
  }

  Future<Result<List<TransactionModel>>> getTransactions(String userId) async {
    try {
      final snapshot =
          await _transactions.where('userId', isEqualTo: userId).get();
      final transactions = snapshot.docs
          .map(TransactionModel.fromFirestore)
          .toList()
        ..sort((left, right) => right.timestamp.compareTo(left.timestamp));
      return Success(transactions);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(
            error.message ?? 'Could not load your transaction history.'),
      );
    }
  }

  Future<Result<void>> deleteTransaction(String id) async {
    try {
      await _transactions.doc(id).delete();
      return const Success(null);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not remove this transaction.'),
      );
    }
  }
}
