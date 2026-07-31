import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;
  final Duration processingDelay;

  PaymentBloc(
    this._repository, {
    this.processingDelay = const Duration(milliseconds: 900),
  }) : super(const PaymentState()) {
    on<PaymentNetworkSelected>(
      (event, emit) =>
          emit(state.copyWith(network: event.network, clearError: true)),
    );
    on<PaymentPhoneChanged>(
      (event, emit) => emit(
          state.copyWith(phoneNumber: event.phoneNumber, clearError: true)),
    );
    on<PaymentPinChanged>(
      (event, emit) => emit(state.copyWith(pin: event.pin, clearError: true)),
    );
    on<PaymentSubmitted>(_onPaymentSubmitted);
    on<PaymentRetryRequested>((event, emit) {
      emit(state.copyWith(
        status: PaymentProcessStatus.ready,
        clearCurrentTransaction: true,
        clearPin: true,
        clearError: true,
      ));
    });
    on<TransactionsRequested>(_onTransactionsRequested);
    on<TransactionDeleteRequested>(_onTransactionDeleteRequested);
  }

  Future<void> _onPaymentSubmitted(
    PaymentSubmitted event,
    Emitter<PaymentState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(state.copyWith(
        status: PaymentProcessStatus.failure,
        errorMessage: state.phoneError ?? state.pinError,
      ));
      return;
    }

    emit(state.copyWith(
      status: PaymentProcessStatus.processing,
      clearCurrentTransaction: true,
      clearError: true,
    ));
    final pending = TransactionModel(
      id: '',
      transactionId: _newTransactionId(),
      userId: event.appointment.userId,
      amount: event.appointment.amount,
      network: state.network,
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
      appointmentId: event.appointment.id,
    );
    final creation = await _repository.createTransaction(pending);
    switch (creation) {
      case ResultError(failure: final failure):
        emit(state.copyWith(
          status: PaymentProcessStatus.failure,
          errorMessage: failure.message,
          clearPin: true,
        ));
      case Success(data: final transaction):
        await Future<void>.delayed(processingDelay);
        final completion = await _repository.completeTransaction(
          transaction,
          TransactionStatus.successful,
        );
        switch (completion) {
          case Success(data: final completed):
            emit(state.copyWith(
              status: completed.status == TransactionStatus.successful
                  ? PaymentProcessStatus.success
                  : PaymentProcessStatus.failure,
              transactions: [completed, ...state.transactions],
              currentTransaction: completed,
              errorMessage: completed.status == TransactionStatus.failed
                  ? 'The payment was declined. Check your details and try again.'
                  : null,
              clearPin: true,
              clearError: completed.status == TransactionStatus.successful,
            ));
          case ResultError(failure: final failure):
            emit(state.copyWith(
              status: PaymentProcessStatus.failure,
              errorMessage: failure.message,
              clearPin: true,
            ));
        }
    }
  }

  Future<void> _onTransactionsRequested(
    TransactionsRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(
        state.copyWith(status: PaymentProcessStatus.loading, clearError: true));
    final result = await _repository.getTransactions(event.userId);
    switch (result) {
      case Success(data: final transactions):
        emit(state.copyWith(
          status: PaymentProcessStatus.ready,
          transactions: transactions,
        ));
      case ResultError(failure: final failure):
        emit(state.copyWith(
          status: PaymentProcessStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> _onTransactionDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<PaymentState> emit,
  ) async {
    final result = await _repository.deleteTransaction(event.transactionId);
    switch (result) {
      case Success():
        emit(state.copyWith(
          status: PaymentProcessStatus.ready,
          transactions: state.transactions
              .where((transaction) => transaction.id != event.transactionId)
              .toList(),
        ));
      case ResultError(failure: final failure):
        emit(state.copyWith(
          status: PaymentProcessStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  String _newTransactionId() {
    final random = Random();
    final suffix = List.generate(6, (_) => random.nextInt(10)).join();
    return 'SOL-${DateTime.now().millisecondsSinceEpoch}-$suffix';
  }
}
