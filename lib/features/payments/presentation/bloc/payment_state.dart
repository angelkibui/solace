import 'package:equatable/equatable.dart';

import '../../data/models/transaction_model.dart';

enum PaymentProcessStatus {
  initial,
  loading,
  ready,
  processing,
  success,
  failure
}

class PaymentState extends Equatable {
  final PaymentProcessStatus status;
  final PaymentNetwork network;
  final String phoneNumber;
  final String pin;
  final List<TransactionModel> transactions;
  final TransactionModel? currentTransaction;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentProcessStatus.initial,
    this.network = PaymentNetwork.mtn,
    this.phoneNumber = '',
    this.pin = '',
    this.transactions = const [],
    this.currentTransaction,
    this.errorMessage,
  });

  String get normalizedPhoneNumber {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('250')) return digits;
    if (digits.startsWith('0')) return '250${digits.substring(1)}';
    if (digits.startsWith('7')) return '250$digits';
    return digits;
  }

  String? get phoneError {
    if (phoneNumber.trim().isEmpty) return 'Enter your mobile money number.';
    if (!RegExp(r'^2507\d{8}$').hasMatch(normalizedPhoneNumber)) {
      return 'Enter a valid Rwandan phone number.';
    }
    return null;
  }

  String? get pinError {
    if (!RegExp(r'^\d{5}$').hasMatch(pin)) return 'Enter a valid 5-digit PIN.';
    return null;
  }

  bool get canSubmit => phoneError == null && pinError == null;

  PaymentState copyWith({
    PaymentProcessStatus? status,
    PaymentNetwork? network,
    String? phoneNumber,
    String? pin,
    List<TransactionModel>? transactions,
    TransactionModel? currentTransaction,
    String? errorMessage,
    bool clearPin = false,
    bool clearCurrentTransaction = false,
    bool clearError = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      network: network ?? this.network,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pin: clearPin ? '' : pin ?? this.pin,
      transactions: transactions ?? this.transactions,
      currentTransaction: clearCurrentTransaction
          ? null
          : currentTransaction ?? this.currentTransaction,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        network,
        phoneNumber,
        pin,
        transactions,
        currentTransaction,
        errorMessage,
      ];
}
