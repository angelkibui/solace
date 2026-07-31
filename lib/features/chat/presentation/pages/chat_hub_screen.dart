import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';
import '../../../appointments/presentation/bloc/appointment_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../therapists/data/models/therapist_model.dart';
import '../../../therapists/presentation/bloc/therapist_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import '../bloc/chat_bloc.dart';
import 'chat_room_screen.dart';

/// Chat hub tab (Part J).
///
/// Shows a list of confirmed appointments — each one represents a conversation
/// the user can open with the assigned therapist. The anonymous chat model
/// means the user is always identified only by their alias.
class ChatHubScreen extends StatelessWidget {
  const ChatHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Messages',
        showBackButton: false,
      ),
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, apptState) {
          if (apptState.status == AppointmentStatusState.loading &&
              apptState.appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final therapistState = context.watch<TherapistBloc>().state;
          final confirmed = apptState.appointments
              .where((appointment) =>
                  appointment.status == AppointmentStatus.confirmed)
              .toList();

          if (confirmed.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No conversations yet',
              subtitle:
                  'Book and confirm a session with a therapist to start an anonymous chat.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: confirmed.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final appt = confirmed[index];
              return _ConversationTile(
                appointment: appt,
                therapist: _findTherapist(
                  therapistState.therapists,
                  appt.therapistId,
                ),
              );
            },
          );
        },
      ),
    );
  }

  TherapistModel? _findTherapist(
    List<TherapistModel> therapists,
    String therapistId,
  ) {
    for (final therapist in therapists) {
      if (therapist.id == therapistId) return therapist;
    }
    return null;
  }
}

class _ConversationTile extends StatelessWidget {
  final AppointmentModel appointment;
  final TherapistModel? therapist;

  const _ConversationTile({
    required this.appointment,
    required this.therapist,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = switch (authState) {
      AuthAuthenticated(user: final u) => u,
      _ => null,
    };
    if (user == null) return const SizedBox.shrink();

    final professional = therapist;
    final canOpen = professional != null && professional.providerUid.isNotEmpty;
    final initial = professional?.name.isNotEmpty == true
        ? professional!.name[0].toUpperCase()
        : 'T';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Text(
          initial,
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
        ),
      ),
      title: Text(
        professional?.name ?? 'Therapist unavailable',
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        canOpen
            ? _sessionLabel(appointment)
            : 'Chat is not available for this session.',
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        canOpen ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: !canOpen
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => ChatBloc(ChatRepository()),
                    child: ChatRoomScreen(
                      chatId: appointment.id,
                      currentUserId: user.uid,
                      currentUserAlias: user.alias,
                      therapistId: professional.id,
                      providerUid: professional.providerUid,
                      therapistName: professional.name,
                    ),
                  ),
                ),
              ),
    );
  }

  String _sessionLabel(AppointmentModel appt) {
    return '${appt.status.label} · ${appt.sessionType.label}';
  }
}
