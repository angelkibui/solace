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
  String? _chatId;
  String? _currentUserId;
  String? _currentUserAlias;

  ChatBloc(this._chatRepository) : super(const ChatInitial()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessagesUpdated>(_onMessagesUpdated);
    on<ChatStreamFailed>(_onStreamFailed);
  }

  Future<void> _onStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSub?.cancel();
    emit(const ChatLoading());

    final chat = await _chatRepository.ensureChat(
      appointmentId: event.chatId,
      currentUserId: event.currentUserId,
      therapistId: event.therapistId,
      providerUid: event.providerUid,
    );
    switch (chat) {
      case ResultError(failure: final failure):
        emit(ChatError(failure.message));
        return;
      case Success():
        _chatId = event.chatId;
        _currentUserId = event.currentUserId;
        _currentUserAlias = event.currentUserAlias;
        _messagesSub = _chatRepository.messagesStream(event.chatId).listen(
              (messages) => add(ChatMessagesUpdated(messages)),
              onError: (_, __) => add(const ChatStreamFailed()),
            );
    }
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    final chatId = _chatId;
    final currentUserId = _currentUserId;
    final currentUserAlias = _currentUserAlias;
    final text = event.text.trim();
    if (current is! ChatLoaded ||
        chatId == null ||
        currentUserId == null ||
        currentUserAlias == null ||
        text.isEmpty ||
        text.length > 2000) {
      return;
    }

    emit(current.copyWith(isSending: true, clearError: true));
    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      senderAlias: currentUserAlias,
      text: text,
      createdAt: DateTime.now(),
    );

    final result = await _chatRepository.sendMessage(
      chatId: chatId,
      message: message,
    );
    result.fold(
      (failure) => emit(current.copyWith(
        isSending: false,
        errorMessage: failure.message,
      )),
      (_) {
        final latest = state;
        if (latest is ChatLoaded) {
          emit(latest.copyWith(isSending: false, clearError: true));
        }
      },
    );
  }

  void _onMessagesUpdated(
    ChatMessagesUpdated event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    emit(ChatLoaded(
      messages: event.messages,
      isSending: current is ChatLoaded && current.isSending,
      errorMessage: current is ChatLoaded ? current.errorMessage : null,
    ));

    final chatId = _chatId;
    final currentUserId = _currentUserId;
    if (chatId != null && currentUserId != null) {
      unawaited(
        _chatRepository.markAsRead(
          chatId: chatId,
          currentUserId: currentUserId,
        ),
      );
    }
  }

  void _onStreamFailed(ChatStreamFailed event, Emitter<ChatState> emit) {
    emit(const ChatError(
      'Could not load messages. Check your connection and try again.',
    ));
  }

  @override
  Future<void> close() async {
    await _messagesSub?.cancel();
    return super.close();
  }
}
