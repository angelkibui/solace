import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final bool isSending;

  const ChatLoaded({required this.messages, this.isSending = false});

  ChatLoaded copyWith({List<MessageModel>? messages, bool? isSending}) =>
      ChatLoaded(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
      );

  @override
  List<Object?> get props => [messages, isSending];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
