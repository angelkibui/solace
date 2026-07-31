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
  final String? errorMessage;

  const ChatLoaded({
    required this.messages,
    this.isSending = false,
    this.errorMessage,
  });

  ChatLoaded copyWith({
    List<MessageModel>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ChatLoaded(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [messages, isSending, errorMessage];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
