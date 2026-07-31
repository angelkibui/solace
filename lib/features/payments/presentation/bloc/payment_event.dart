import 'package:equatable/equatable.dart';

import '../../../appointments/data/models/appointment_model.dart';
import '../../data/models/transaction_model.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class PaymentNetworkSelected extends PaymentEvent {
  final PaymentNetwork network;

  const PaymentNetworkSelected(this.network);

  @override
  List<Object?> get props => [network];
}

class PaymentPhoneChanged extends PaymentEvent {
  final String phoneNumber;

  const PaymentPhoneChanged(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class PaymentPinChanged extends PaymentEvent {
  final String pin;

  const PaymentPinChanged(this.pin);

  @override
  List<Object?> get props => [pin];
}

class PaymentSubmitted extends PaymentEvent {
  final AppointmentModel appointment;

  const PaymentSubmitted(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class PaymentRetryRequested extends PaymentEvent {
  const PaymentRetryRequested();
}

class TransactionsRequested extends PaymentEvent {
  final String userId;

  const TransactionsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class TransactionDeleteRequested extends PaymentEvent {
  final String transactionId;

  const TransactionDeleteRequested(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}
