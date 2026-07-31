import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the chat screen mounts to begin the messages stream.
class ChatStarted extends ChatEvent {
  final String chatId;
  final String currentUserId;
  const ChatStarted({required this.chatId, required this.currentUserId});

  @override
  List<Object?> get props => [chatId, currentUserId];
}

/// Fired when the user taps the send button.
class ChatMessageSent extends ChatEvent {
  final String chatId;
  final String senderId;
  final String senderAlias;
  final String text;

  const ChatMessageSent({
    required this.chatId,
    required this.senderId,
    required this.senderAlias,
    required this.text,
  });

  @override
  List<Object?> get props => [chatId, senderId, text];
}
