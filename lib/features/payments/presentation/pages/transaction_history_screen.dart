import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Wallet Activity'),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          final successful = state.transactions
              .where((transaction) =>
                  transaction.status == TransactionStatus.successful)
              .toList();
          final total = successful.fold<int>(
              0, (sum, transaction) => sum + transaction.amount);
          return Column(
            children: [
              _WalletSummary(total: total, successfulCount: successful.length),
              Expanded(
                child: state.transactions.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.receipt_long_outlined,
                        title: 'No transactions yet',
                        subtitle:
                            'Completed and failed payment attempts appear here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: state.transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final transaction = state.transactions[index];
                          return Dismissible(
                            key: ValueKey(transaction.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Remove transaction?'),
                                content: const Text(
                                    'This removes the record from your history.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('Keep'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (_) => context.read<PaymentBloc>().add(
                                  TransactionDeleteRequested(transaction.id),
                                ),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.white),
                            ),
                            child: _TransactionTile(transaction: transaction),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WalletSummary extends StatelessWidget {
  final int total;
  final int successfulCount;

  const _WalletSummary({required this.total, required this.successfulCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Successful session payments',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            '${NumberFormat.decimalPattern().format(total)} RWF',
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
              '$successfulCount completed transaction${successfulCount == 1 ? '' : 's'}',
              style: AppTextStyles.caption.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = switch (transaction.status) {
      TransactionStatus.successful => AppColors.primary,
      TransactionStatus.failed => AppColors.error,
      TransactionStatus.pending => AppColors.warning,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.receipt_long_rounded, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.network.label,
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('d MMM yyyy · h:mm a')
                        .format(transaction.timestamp),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.status.label,
                    style: AppTextStyles.caption
                        .copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Text(
              '${NumberFormat.decimalPattern().format(transaction.amount)} RWF',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
