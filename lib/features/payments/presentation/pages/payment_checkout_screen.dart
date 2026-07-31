import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';
import '../../../appointments/presentation/bloc/appointment_event.dart';
import '../../../therapists/data/models/therapist_model.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import 'payment_result_screen.dart';

class PaymentCheckoutScreen extends StatelessWidget {
  final AppointmentModel appointment;
  final TherapistModel therapist;

  const PaymentCheckoutScreen({
    super.key,
    required this.appointment,
    required this.therapist,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listenWhen: (previous, current) =>
          previous.currentTransaction?.id != current.currentTransaction?.id ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final transaction = state.currentTransaction;
        if (transaction != null &&
            transaction.status != TransactionStatus.pending) {
          if (transaction.status == TransactionStatus.successful) {
            context.read<AppointmentBloc>().add(
                  AppointmentsRequested(appointment.userId),
                );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<PaymentBloc>()),
                    BlocProvider.value(value: context.read<AppointmentBloc>()),
                  ],
                  child: PaymentResultScreen(
                    transaction: transaction,
                    appointment: appointment,
                    therapistName: therapist.name,
                  ),
                ),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<PaymentBloc>(),
                  child: PaymentResultScreen(
                    transaction: transaction,
                    appointment: appointment,
                    therapistName: therapist.name,
                  ),
                ),
              ),
            );
          }
          return;
        }
        if (state.errorMessage != null && transaction == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(title: 'Therapy Checkout'),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SecurePaymentBadge(),
                            const SizedBox(height: 16),
                            _AmountCard(
                                appointment: appointment, therapist: therapist),
                            const SizedBox(height: 24),
                            Text('Select network',
                                style: AppTextStyles.titleMedium),
                            const SizedBox(height: 12),
                            Row(
                              children: PaymentNetwork.values.map((network) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: network == PaymentNetwork.mtn
                                          ? 10
                                          : 0,
                                    ),
                                    child: _NetworkCard(
                                      network: network,
                                      selected: state.network == network,
                                      onTap: () =>
                                          context.read<PaymentBloc>().add(
                                                PaymentNetworkSelected(network),
                                              ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 22),
                            TextField(
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+ ]')),
                                LengthLimitingTextInputFormatter(16),
                              ],
                              onChanged: (value) =>
                                  context.read<PaymentBloc>().add(
                                        PaymentPhoneChanged(value),
                                      ),
                              decoration: InputDecoration(
                                labelText: 'Mobile money number',
                                hintText: '+250 78 000 0000',
                                prefixIcon:
                                    const Icon(Icons.phone_android_rounded),
                                errorText: state.phoneNumber.isEmpty
                                    ? null
                                    : state.phoneError,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                              onChanged: (value) =>
                                  context.read<PaymentBloc>().add(
                                        PaymentPinChanged(value),
                                      ),
                              decoration: InputDecoration(
                                labelText: 'Mobile money PIN',
                                hintText: 'Enter your 5-digit PIN',
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                errorText:
                                    state.pin.isEmpty ? null : state.pinError,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SolaceButton(
                      label: 'Pay with MoMo',
                      icon: Icons.shield_outlined,
                      width: double.infinity,
                      isLoading:
                          state.status == PaymentProcessStatus.processing,
                      onPressed: state.canSubmit
                          ? () => context.read<PaymentBloc>().add(
                                PaymentSubmitted(appointment),
                              )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SecurePaymentBadge extends StatelessWidget {
  const _SecurePaymentBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          '◉  SECURE LOCAL PAYMENT',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final AppointmentModel appointment;
  final TherapistModel therapist;

  const _AmountCard({required this.appointment, required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Text('Payable amount', style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              'RWF ${NumberFormat.decimalPattern().format(appointment.amount)}',
              style: AppTextStyles.displayLarge.copyWith(fontSize: 38),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${therapist.name} · ${appointment.sessionType.label} session',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NetworkCard extends StatelessWidget {
  final PaymentNetwork network;
  final bool selected;
  final VoidCallback onTap;

  const _NetworkCard(
      {required this.network, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brandColor = network == PaymentNetwork.mtn
        ? const Color(0xFFFFCB05)
        : const Color(0xFFE4002B);
    return Semantics(
      button: true,
      selected: selected,
      label: network.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 104,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? brandColor.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? brandColor : Theme.of(context).dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: brandColor, shape: BoxShape.circle),
                child: Text(
                  network == PaymentNetwork.mtn ? 'MTN' : 'airtel',
                  style: AppTextStyles.caption.copyWith(
                    color: network == PaymentNetwork.mtn
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(network.label, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
