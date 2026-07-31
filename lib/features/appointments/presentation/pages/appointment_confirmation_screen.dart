import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../data/models/appointment_model.dart';
import '../bloc/appointment_bloc.dart';
import 'my_appointments_screen.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  final AppointmentModel appointment;
  final String therapistName;

  const AppointmentConfirmationScreen({
    super.key,
    required this.appointment,
    required this.therapistName,
  });

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
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Your slot is reserved',
                      style: AppTextStyles.headingLarge),
                  const SizedBox(height: 10),
                  Text(
                    'Complete payment to confirm your private session.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(therapistName,
                              style: AppTextStyles.headingSmall),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy · h:mm a')
                                .format(appointment.dateTime),
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appointment.sessionType.label,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                    label: 'Back to Professionals',
                    variant: SolaceButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
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
