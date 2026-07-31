import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/chat_bubble.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

/// Full-screen chat room between the current user and their therapist.
/// Opened from [ChatHubScreen]; receives its own [ChatBloc] from the parent.
class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String currentUserAlias;
  final String therapistId;
  final String providerUid;
  final String therapistName;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.currentUserAlias,
    required this.therapistId,
    required this.providerUid,
    required this.therapistName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _pendingText;
  String? _shownError;

  @override
  void initState() {
    super.initState();
    _startChat();
  }

  void _startChat() => context.read<ChatBloc>().add(
        ChatStarted(
          chatId: widget.chatId,
          currentUserId: widget.currentUserId,
          currentUserAlias: widget.currentUserAlias,
          therapistId: widget.therapistId,
          providerUid: widget.providerUid,
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final state = context.read<ChatBloc>().state;
    if (state is! ChatLoaded || state.isSending) return;
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > 2000) return;
    _pendingText = text;
    context.read<ChatBloc>().add(ChatMessageSent(text));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.therapistName,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Anonymous',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            _scrollToBottom();
            final error = state.errorMessage;
            if (_pendingText != null && !state.isSending) {
              if (error == null && _controller.text.trim() == _pendingText) {
                _controller.clear();
              }
              _pendingText = null;
            }
            if (error == null) {
              _shownError = null;
            } else if (error != _shownError) {
              _shownError = error;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // ── Anonymity notice banner ─────────────────────────────────
              _AnonymityBanner(alias: widget.currentUserAlias),

              // ── Message list ────────────────────────────────────────────
              Expanded(child: _buildMessageList(state)),

              // ── Input bar ───────────────────────────────────────────────
              _MessageInputBar(
                controller: _controller,
                isSending: state is ChatLoaded && state.isSending,
                onSend: _sendMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state is ChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatLoaded) {
      if (state.messages.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'No messages yet',
          subtitle: 'Send a message to start the conversation.',
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          final isMine = message.senderId == widget.currentUserId;

          // Show a date separator when the day changes.
          final showDate = index == 0 ||
              !_isSameDay(
                message.createdAt,
                state.messages[index - 1].createdAt,
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDate) _DateSeparator(date: message.createdAt),
              ChatBubble(
                text: message.text,
                timestamp: message.createdAt,
                isSentByMe: isMine,
                isRead: message.isRead,
              ),
            ],
          );
        },
      );
    }

    if (state is ChatError) {
      return EmptyStateWidget(
        icon: Icons.cloud_off_rounded,
        title: 'Conversation unavailable',
        subtitle: state.message,
        actionLabel: 'Try again',
        onAction: _startChat,
      );
    }

    // ChatInitial / ChatError — show nothing in the list area
    return const SizedBox.shrink();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Local widgets ────────────────────────────────────────────────────────────

class _AnonymityBanner extends StatelessWidget {
  final String alias;
  const _AnonymityBanner({required this.alias});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      color: isDark
          ? AppColors.darkSurface
          : AppColors.primary.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Chatting as "$alias". Your alias is shown in this conversation.',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final daysAgo = today.difference(messageDay).inDays;
    final label = daysAgo == 0
        ? 'Today'
        : daysAgo == 1
            ? 'Yesterday'
            : '${date.day}/${date.month}/${date.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: AppTextStyles.caption),
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: 8 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isSending,
                minLines: 1,
                maxLines: 5,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.darkBackground : AppColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSending
                  ? const SizedBox(
                      key: ValueKey('spinner'),
                      width: 44,
                      height: 44,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : IconButton(
                      key: const ValueKey('send'),
                      onPressed: onSend,
                      tooltip: 'Send',
                      icon: const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(44, 44),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
