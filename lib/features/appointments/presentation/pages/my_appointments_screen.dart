import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/appointment_model.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_state.dart';
import 'appointment_detail_screen.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'My Appointments'),
        body: BlocConsumer<AppointmentBloc, AppointmentState>(
          listenWhen: (previous, current) =>
              previous.actionMessage != current.actionMessage ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            final message = state.errorMessage ?? state.actionMessage;
            if (message != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) {
            final now = DateTime.now();
            final upcoming = state.appointments
                .where((appointment) =>
                    appointment.dateTime.isAfter(now) &&
                    appointment.status != AppointmentStatus.cancelled &&
                    appointment.status != AppointmentStatus.completed)
                .toList();
            final history = state.appointments
                .where((appointment) =>
                    !appointment.dateTime.isAfter(now) ||
                    appointment.status == AppointmentStatus.cancelled ||
                    appointment.status == AppointmentStatus.completed)
                .toList();

            return Column(
              children: [
                const TabBar(
                  tabs: [Tab(text: 'Upcoming'), Tab(text: 'History')],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AppointmentList(
                        appointments: upcoming,
                        therapistNames: state.therapistNames,
                        emptyTitle: 'No upcoming sessions',
                        emptySubtitle:
                            'Book a professional when you feel ready.',
                      ),
                      _AppointmentList(
                        appointments: history,
                        therapistNames: state.therapistNames,
                        emptyTitle: 'No appointment history',
                        emptySubtitle:
                            'Completed and cancelled sessions appear here.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final Map<String, String> therapistNames;
  final String emptyTitle;
  final String emptySubtitle;

  const _AppointmentList({
    required this.appointments,
    required this.therapistNames,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_available_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final therapistName =
            therapistNames[appointment.therapistId] ?? 'Solace Professional';
        return _AppointmentCard(
          appointment: appointment,
          therapistName: therapistName,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AppointmentBloc>(),
                child: AppointmentDetailScreen(
                  appointment: appointment,
                  therapistName: therapistName,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final String therapistName;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.therapistName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (appointment.status) {
      AppointmentStatus.confirmed => AppColors.primary,
      AppointmentStatus.pendingPayment => AppColors.warning,
      AppointmentStatus.completed => AppColors.info,
      AppointmentStatus.cancelled => AppColors.error,
    };
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM')
                          .format(appointment.dateTime)
                          .toUpperCase(),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                    ),
                    Text('${appointment.dateTime.day}',
                        style: AppTextStyles.headingMedium),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(therapistName, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('h:mm a').format(appointment.dateTime)} · ${appointment.sessionType.label}',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        appointment.status.label,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
