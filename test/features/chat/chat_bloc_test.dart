import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solace/core/utils/failure.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/chat/data/models/message_model.dart';
import 'package:solace/features/chat/data/repositories/chat_repository.dart';
import 'package:solace/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:solace/features/chat/presentation/bloc/chat_event.dart';
import 'package:solace/features/chat/presentation/bloc/chat_state.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late StreamController<List<MessageModel>> messages;

  const started = ChatStarted(
    chatId: 'appointment-1',
    currentUserId: 'user-1',
    currentUserAlias: 'QuietRiver',
    therapistId: 'therapist-1',
    providerUid: 'provider-1',
  );

  setUpAll(() {
    registerFallbackValue(MessageModel(
      id: '',
      senderId: 'fallback',
      senderAlias: 'Fallback',
      text: 'Fallback',
      createdAt: DateTime.utc(2026),
    ));
  });

  setUp(() {
    repository = MockChatRepository();
    messages = StreamController<List<MessageModel>>.broadcast();
    when(() => repository.ensureChat(
          appointmentId: any(named: 'appointmentId'),
          currentUserId: any(named: 'currentUserId'),
          therapistId: any(named: 'therapistId'),
          providerUid: any(named: 'providerUid'),
        )).thenAnswer((_) async => const Success(null));
    when(() => repository.messagesStream(any()))
        .thenAnswer((_) => messages.stream);
    when(() => repository.markAsRead(
          chatId: any(named: 'chatId'),
          currentUserId: any(named: 'currentUserId'),
        )).thenAnswer((_) async => const Success(null));
  });

  tearDown(() async => messages.close());

  blocTest<ChatBloc, ChatState>(
    'keeps the message stream active while sending with trusted identity',
    setUp: () {
      when(() => repository.sendMessage(
            chatId: any(named: 'chatId'),
            message: any(named: 'message'),
          )).thenAnswer((_) async => const Success(null));
    },
    build: () => ChatBloc(repository),
    act: (bloc) async {
      bloc.add(started);
      await Future<void>.delayed(Duration.zero);
      messages.add(const []);
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ChatMessageSent(' Hello '));
    },
    wait: const Duration(milliseconds: 20),
    verify: (_) {
      final captured = verify(() => repository.sendMessage(
            chatId: 'appointment-1',
            message: captureAny(named: 'message'),
          )).captured.single as MessageModel;
      expect(captured.senderId, 'user-1');
      expect(captured.senderAlias, 'QuietRiver');
      expect(captured.text, 'Hello');
    },
  );

  blocTest<ChatBloc, ChatState>(
    'reports chat initialization failures without subscribing',
    setUp: () {
      when(() => repository.ensureChat(
                appointmentId: any(named: 'appointmentId'),
                currentUserId: any(named: 'currentUserId'),
                therapistId: any(named: 'therapistId'),
                providerUid: any(named: 'providerUid'),
              ))
          .thenAnswer((_) async =>
              const ResultError(AuthFailure('Conversation denied.')));
    },
    build: () => ChatBloc(repository),
    act: (bloc) => bloc.add(started),
    expect: () => const [
      ChatLoading(),
      ChatError('Conversation denied.'),
    ],
    verify: (_) => verifyNever(() => repository.messagesStream(any())),
  );
}
