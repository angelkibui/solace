import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<List<MessageModel>>? _messagesSub;

  ChatBloc(this._chatRepository) : super(const ChatInitial()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessageSent>(_onMessageSent);
  }

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    await emit.forEach(
      _chatRepository.messagesStream(event.chatId),
      onData: (messages) => ChatLoaded(messages: messages),
      onError: (_, __) =>
          const ChatError('Could not load messages. Check your connection.'),
    );
    // Mark received messages as read in the background.
    _chatRepository.markAsRead(
      chatId: event.chatId,
      currentUserId: event.currentUserId,
    );
  }

  Future<void> _onMessageSent(
      ChatMessageSent event, Emitter<ChatState> emit) async {
    final current = state;
    if (current is! ChatLoaded) return;

    emit(current.copyWith(isSending: true));

    final message = MessageModel(
      id: '',
      senderId: event.senderId,
      senderAlias: event.senderAlias,
      text: event.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await _chatRepository.sendMessage(
      chatId: event.chatId,
      message: message,
    );

    result.fold(
      (failure) {
        emit(current.copyWith(isSending: false));
        // Surface the error as a separate state that ChatScreen can listen to.
        emit(ChatError(failure.message));
        emit(current.copyWith(isSending: false));
      },
      (_) => emit(current.copyWith(isSending: false)),
    );
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
