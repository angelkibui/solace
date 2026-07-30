import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../data/models/appointment_model.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentModel appointment;
  final String therapistName;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
    required this.therapistName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final current = state.appointments.firstWhere(
          (item) => item.id == appointment.id,
          orElse: () => appointment,
        );
        return Scaffold(
          appBar: const CustomAppBar(title: 'Appointment Details'),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 34,
                              backgroundColor: AppColors.surface,
                              child: Icon(Icons.person_rounded,
                                  color: AppColors.primary, size: 34),
                            ),
                            const SizedBox(height: 12),
                            Text(therapistName,
                                style: AppTextStyles.headingMedium),
                            const SizedBox(height: 5),
                            Text(current.status.label,
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.calendar_month_rounded,
                                label: 'Date',
                                value: DateFormat('EEEE, d MMMM yyyy')
                                    .format(current.dateTime),
                              ),
                              const Divider(height: 28),
                              _DetailRow(
                                icon: Icons.schedule_rounded,
                                label: 'Time',
                                value: DateFormat('h:mm a')
                                    .format(current.dateTime),
                              ),
                              const Divider(height: 28),
                              _DetailRow(
                                icon: Icons.self_improvement_rounded,
                                label: 'Session',
                                value: current.sessionType.label,
                              ),
                              const Divider(height: 28),
                              _DetailRow(
                                icon: Icons.payments_outlined,
                                label: 'Amount',
                                value:
                                    '${NumberFormat.decimalPattern().format(current.amount)} RWF',
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (current.notes.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Private note',
                                      style: AppTextStyles.titleMedium),
                                  const SizedBox(height: 8),
                                  Text(current.notes,
                                      style: AppTextStyles.bodyMedium),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (current.status != AppointmentStatus.cancelled &&
                          current.status != AppointmentStatus.completed) ...[
                        SolaceButton(
                          label: 'Reschedule',
                          variant: SolaceButtonVariant.outline,
                          icon: Icons.edit_calendar_outlined,
                          onPressed: () => _reschedule(context, current),
                        ),
                        const SizedBox(height: 10),
                        SolaceButton(
                          label: 'Cancel Appointment',
                          variant: SolaceButtonVariant.outline,
                          onPressed: () => _cancel(context, current),
                        ),
                      ] else
                        SolaceButton(
                          label: 'Remove from History',
                          variant: SolaceButtonVariant.outline,
                          onPressed: () => _delete(context, current),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _reschedule(
      BuildContext context, AppointmentModel current) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current.dateTime.isAfter(DateTime.now())
          ? current.dateTime
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current.dateTime),
    );
    if (time == null || !context.mounted) return;
    context.read<AppointmentBloc>().add(
          AppointmentRescheduleRequested(
            current,
            DateTime(date.year, date.month, date.day, time.hour, time.minute),
          ),
        );
  }

  Future<void> _cancel(BuildContext context, AppointmentModel current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: const Text('Your reserved time will be released.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AppointmentBloc>().add(AppointmentCancelRequested(current));
    }
  }

  Future<void> _delete(BuildContext context, AppointmentModel current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove appointment?'),
        content: const Text(
            'This permanently removes the record from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<AppointmentBloc>()
          .add(AppointmentDeleteRequested(current.id));
      Navigator.of(context).pop();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
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
