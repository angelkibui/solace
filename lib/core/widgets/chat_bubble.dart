import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A single chat message bubble. Sent vs. received styling flips
/// alignment and color; [isRead] shows a double-check receipt on sent
/// messages only, matching common messaging-app conventions.
class ChatBubble extends StatelessWidget {
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;
  final bool isRead;

  const ChatBubble({
    super.key,
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isSentByMe
        ? AppColors.bubbleSent
        : (isDark ? AppColors.darkBubbleReceived : AppColors.bubbleReceived);
    final textColor = isSentByMe ? Colors.white : null;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
            bottomRight: Radius.circular(isSentByMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: isSentByMe ? Colors.white.withValues(alpha: 0.75) : AppColors.textSecondary,
                  ),
                ),
                if (isSentByMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: isRead ? Colors.lightBlueAccent : Colors.white.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
