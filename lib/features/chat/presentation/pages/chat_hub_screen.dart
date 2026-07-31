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

          // Only show confirmed or pending appointments — those have an assigned
          // therapist the user can message.
          final confirmed = apptState.appointments
              .where((a) =>
                  a.status == AppointmentStatus.confirmed ||
                  a.status == AppointmentStatus.pendingPayment)
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
              return _ConversationTile(appointment: appt);
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final AppointmentModel appointment;
  const _ConversationTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = switch (authState) {
      AuthAuthenticated(user: final u) => u,
      _ => null,
    };
    if (user == null) return const SizedBox.shrink();

    final chatId = ChatRepository.chatId(user.uid, appointment.therapistId);
    // Use first char of therapistId as fallback avatar initial.
    final initial = appointment.therapistId.isNotEmpty
        ? appointment.therapistId[0].toUpperCase()
        : 'T';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Text(
          initial,
          style: AppTextStyles.titleMedium
              .copyWith(color: AppColors.primary),
        ),
      ),
      title: Text(
        'Therapist session',
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        _sessionLabel(appointment),
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ChatBloc(ChatRepository()),
            child: ChatRoomScreen(
              chatId: chatId,
              currentUserId: user.uid,
              currentUserAlias: user.alias,
              therapistName: 'Your Therapist',
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

