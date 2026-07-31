import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../therapists/data/models/therapist_model.dart';
import '../../data/models/appointment_model.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
import 'appointment_confirmation_screen.dart';

class BookingFlowScreen extends StatefulWidget {
  final String userId;
  final TherapistModel therapist;
  final ValueChanged<AppointmentModel>? onAppointmentCreated;

  const BookingFlowScreen({
    super.key,
    required this.userId,
    required this.therapist,
    this.onAppointmentCreated,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(const BookingDraftCleared());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listenWhen: (previous, current) =>
          previous.bookingStep != current.bookingStep ||
          previous.lastCreatedAppointment?.id !=
              current.lastCreatedAppointment?.id ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.bookingStep) {
          _pageController.animateToPage(
            state.bookingStep,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        final created = state.lastCreatedAppointment;
        if (created != null && created.id.isNotEmpty) {
          if (widget.onAppointmentCreated != null) {
            widget.onAppointmentCreated!(created);
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AppointmentBloc>(),
                  child: AppointmentConfirmationScreen(
                    appointment: created,
                    therapistName: widget.therapist.name,
                  ),
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: _stepTitle(state.bookingStep)),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (state.bookingStep + 1) / 4,
                      minHeight: 6,
                      backgroundColor: AppColors.divider,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _DateStep(therapist: widget.therapist),
                      _TimeStep(therapist: widget.therapist),
                      const _SessionTypeStep(),
                      _ReviewStep(therapist: widget.therapist),
                    ],
                  ),
                ),
                _BookingActions(
                  state: state,
                  onBack: state.bookingStep == 0
                      ? null
                      : () => context.read<AppointmentBloc>().add(
                            BookingStepChanged(state.bookingStep - 1),
                          ),
                  onContinue: state.canContinue
                      ? () {
                          if (state.bookingStep < 3) {
                            context.read<AppointmentBloc>().add(
                                  BookingStepChanged(state.bookingStep + 1),
                                );
                            return;
                          }
                          context.read<AppointmentBloc>().add(
                                AppointmentCreateRequested(
                                  userId: widget.userId,
                                  therapistId: widget.therapist.id,
                                  amount: widget.therapist.rate,
                                ),
                              );
                        }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _stepTitle(int step) => switch (step) {
        0 => 'Choose a Date',
        1 => 'Choose a Time',
        2 => 'Session Type',
        _ => 'Review Booking',
      };
}

class _DateStep extends StatelessWidget {
  final TherapistModel therapist;

  const _DateStep({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      buildWhen: (previous, current) =>
          previous.selectedDate != current.selectedDate,
      builder: (context, state) {
        final now = DateTime.now();
        final firstDate = DateTime(now.year, now.month, now.day);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfessionalSummary(therapist: therapist),
                  const SizedBox(height: 22),
                  Text('Select a convenient day',
                      style: AppTextStyles.headingSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Available times will appear on the next step.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: CalendarDatePicker(
                      initialDate: state.selectedDate ?? firstDate,
                      firstDate: firstDate,
                      lastDate: firstDate.add(const Duration(days: 90)),
                      onDateChanged: (date) =>
                          context.read<AppointmentBloc>().add(
                                BookingDateSelected(date),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimeStep extends StatelessWidget {
  final TherapistModel therapist;

  const _TimeStep({required this.therapist});

  static const fallbackTimes = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 30),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 16, minute: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final availableTimes = _timesForDate(state.selectedDate);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedDate == null
                        ? 'Available times'
                        : DateFormat('EEEE, d MMMM')
                            .format(state.selectedDate!),
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Times are shown in Central Africa Time.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableTimes.map((time) {
                      final selected = state.selectedTime == time;
                      return ChoiceChip(
                        selected: selected,
                        avatar: Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: selected ? Colors.white : AppColors.primary,
                        ),
                        label: Text(time.format(context)),
                        onSelected: (_) => context.read<AppointmentBloc>().add(
                              BookingTimeSelected(time),
                            ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.info),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your slot is reserved when the booking is created and confirmed after payment.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<TimeOfDay> _timesForDate(DateTime? date) {
    if (date == null || therapist.availability.isEmpty) return fallbackTimes;
    final matches = therapist.availability
        .where((slot) =>
            slot.year == date.year &&
            slot.month == date.month &&
            slot.day == date.day)
        .map((slot) => TimeOfDay.fromDateTime(slot))
        .toList();
    return matches.isEmpty ? fallbackTimes : matches;
  }
}

class _SessionTypeStep extends StatelessWidget {
  const _SessionTypeStep();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      buildWhen: (previous, current) =>
          previous.sessionType != current.sessionType,
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('How would you like to meet?',
                style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('Choose the format that feels most supportive.',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 20),
            ...SessionType.values.map((type) {
              final selected = state.sessionType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : null,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.read<AppointmentBloc>().add(
                          BookingSessionTypeSelected(type),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _iconFor(type),
                              color:
                                  selected ? Colors.white : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(type.label,
                                    style: AppTextStyles.titleMedium),
                                const SizedBox(height: 3),
                                Text(type.description,
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  IconData _iconFor(SessionType type) => switch (type) {
        SessionType.individual => Icons.person_outline_rounded,
        SessionType.couples => Icons.people_outline_rounded,
        SessionType.group => Icons.groups_outlined,
      };
}

class _ReviewStep extends StatelessWidget {
  final TherapistModel therapist;

  const _ReviewStep({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final dateTime = state.selectedDateTime;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _ProfessionalSummary(therapist: therapist),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _ReviewRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Date and time',
                      value: dateTime == null
                          ? 'Not selected'
                          : DateFormat('EEE, d MMM · h:mm a').format(dateTime),
                    ),
                    const Divider(height: 28),
                    _ReviewRow(
                      icon: Icons.self_improvement_rounded,
                      label: 'Session',
                      value: state.sessionType.label,
                    ),
                    const Divider(height: 28),
                    _ReviewRow(
                      icon: Icons.payments_outlined,
                      label: 'Amount',
                      value:
                          '${NumberFormat.decimalPattern().format(therapist.rate)} RWF',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              minLines: 3,
              maxLines: 5,
              onChanged: (value) => context.read<AppointmentBloc>().add(
                    BookingNotesChanged(value),
                  ),
              decoration: const InputDecoration(
                labelText: 'Optional private note',
                hintText:
                    'Share anything that may help prepare for the session.',
                alignLabelWithHint: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfessionalSummary extends StatelessWidget {
  final TherapistModel therapist;

  const _ProfessionalSummary({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.person_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(therapist.name, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 3),
                  Text(therapist.title, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.verified_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        Flexible(
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

class _BookingActions extends StatelessWidget {
  final AppointmentState state;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const _BookingActions({required this.state, this.onBack, this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (onBack != null) ...[
              Expanded(
                child: SolaceButton(
                  label: 'Back',
                  variant: SolaceButtonVariant.outline,
                  onPressed: onBack,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: onBack == null ? 1 : 2,
              child: SolaceButton(
                label:
                    state.bookingStep == 3 ? 'Proceed to Payment' : 'Continue',
                isLoading: state.status == AppointmentStatusState.submitting,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
