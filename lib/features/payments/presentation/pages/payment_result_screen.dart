import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';
import '../../../appointments/presentation/pages/my_appointments_screen.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import 'transaction_history_screen.dart';

class PaymentResultScreen extends StatelessWidget {
  final TransactionModel transaction;
  final AppointmentModel appointment;
  final String therapistName;

  const PaymentResultScreen({
    super.key,
    required this.transaction,
    required this.appointment,
    required this.therapistName,
  });

  bool get successful => transaction.status == TransactionStatus.successful;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.7, end: 1),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) => Transform.scale(
                      scale: value,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color:
                            (successful ? AppColors.primary : AppColors.error)
                                .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        successful ? Icons.check_rounded : Icons.close_rounded,
                        color: successful ? AppColors.primary : AppColors.error,
                        size: 54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    successful ? 'Payment successful' : 'Payment unsuccessful',
                    style: AppTextStyles.headingLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    successful
                        ? 'Your private session with $therapistName is confirmed.'
                        : 'No charge was completed. Review your details and try again.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _ResultRow(
                              label: 'Network',
                              value: transaction.network.label),
                          const Divider(height: 26),
                          _ResultRow(
                            label: 'Amount',
                            value:
                                '${NumberFormat.decimalPattern().format(transaction.amount)} RWF',
                          ),
                          const Divider(height: 26),
                          _ResultRow(
                              label: 'Reference',
                              value: transaction.transactionId),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (successful) ...[
                    SolaceButton(
                      label: 'View My Appointments',
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AppointmentBloc>(),
                            child: const MyAppointmentsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SolaceButton(
                      label: 'Transaction History',
                      variant: SolaceButtonVariant.outline,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<PaymentBloc>(),
                            child: const TransactionHistoryScreen(),
                          ),
                        ),
                      ),
                    ),
                  ] else
                    SolaceButton(
                      label: 'Try Again',
                      onPressed: () {
                        context
                            .read<PaymentBloc>()
                            .add(const PaymentRetryRequested());
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
