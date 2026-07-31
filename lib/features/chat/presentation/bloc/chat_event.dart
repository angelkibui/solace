import 'package:equatable/equatable.dart';

import '../../data/models/message_model.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the chat screen mounts to begin the messages stream.
class ChatStarted extends ChatEvent {
  final String chatId;
  final String currentUserId;
  final String currentUserAlias;
  final String therapistId;
  final String providerUid;

  const ChatStarted({
    required this.chatId,
    required this.currentUserId,
    required this.currentUserAlias,
    required this.therapistId,
    required this.providerUid,
  });

  @override
  List<Object?> get props => [
        chatId,
        currentUserId,
        currentUserAlias,
        therapistId,
        providerUid,
      ];
}

/// Fired when the user taps the send button.
class ChatMessageSent extends ChatEvent {
  final String text;

  const ChatMessageSent(this.text);

  @override
  List<Object?> get props => [text];
}

class ChatMessagesUpdated extends ChatEvent {
  final List<MessageModel> messages;

  const ChatMessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatStreamFailed extends ChatEvent {
  const ChatStreamFailed();
}
