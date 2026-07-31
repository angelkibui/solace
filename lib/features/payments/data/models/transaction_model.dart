import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PaymentNetwork { mtn, airtel }

enum TransactionStatus { pending, successful, failed }

extension PaymentNetworkX on PaymentNetwork {
  String get value => name;

  String get label => switch (this) {
        PaymentNetwork.mtn => 'MTN MoMo',
        PaymentNetwork.airtel => 'Airtel Money',
      };

  static PaymentNetwork fromValue(String? value) {
    return PaymentNetwork.values.firstWhere(
      (network) => network.value == value,
      orElse: () => PaymentNetwork.mtn,
    );
  }
}

extension TransactionStatusX on TransactionStatus {
  String get value => name;

  String get label => switch (this) {
        TransactionStatus.pending => 'Processing',
        TransactionStatus.successful => 'Successful',
        TransactionStatus.failed => 'Failed',
      };

  static TransactionStatus fromValue(String? value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TransactionStatus.pending,
    );
  }
}

class TransactionModel extends Equatable {
  final String id;
  final String transactionId;
  final String userId;
  final int amount;
  final PaymentNetwork network;
  final TransactionStatus status;
  final DateTime timestamp;
  final String appointmentId;

  const TransactionModel({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.network,
    required this.status,
    required this.timestamp,
    required this.appointmentId,
  });

  factory TransactionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final map = document.data() ?? const <String, dynamic>{};
    final timestamp = map['timestamp'];
    return TransactionModel(
      id: document.id,
      transactionId: map['transactionId'] as String? ?? document.id,
      userId: map['userId'] as String? ?? '',
      amount: (map['amount'] as num?)?.round() ?? 0,
      network: PaymentNetworkX.fromValue(map['network'] as String?),
      status: TransactionStatusX.fromValue(map['status'] as String?),
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      appointmentId: map['appointmentId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'amount': amount,
      'network': network.value,
      'status': status.value,
      'timestamp': Timestamp.fromDate(timestamp),
      'appointmentId': appointmentId,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? transactionId,
    String? userId,
    int? amount,
    PaymentNetwork? network,
    TransactionStatus? status,
    DateTime? timestamp,
    String? appointmentId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      network: network ?? this.network,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      appointmentId: appointmentId ?? this.appointmentId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionId,
        userId,
        amount,
        network,
        status,
        timestamp,
        appointmentId,
      ];
}
