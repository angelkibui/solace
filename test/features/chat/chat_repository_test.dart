import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solace/core/utils/result.dart';
import 'package:solace/features/chat/data/models/message_model.dart';
import 'package:solace/features/chat/data/repositories/chat_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ChatRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ChatRepository(firestore: firestore);
  });

  test('creates an appointment-scoped chat with exact participants', () async {
    final result = await repository.ensureChat(
      appointmentId: 'appointment-1',
      currentUserId: 'user-1',
      therapistId: 'therapist-1',
      providerUid: 'provider-1',
    );

    expect(result.isSuccess, isTrue);
    final chat = await firestore.collection('chats').doc('appointment-1').get();
    expect(chat.data(), containsPair('appointmentId', 'appointment-1'));
    expect(chat.data(), containsPair('userId', 'user-1'));
    expect(chat.data(), containsPair('therapistId', 'therapist-1'));
    expect(chat.data(), containsPair('providerUid', 'provider-1'));
  });

  test('rejects a different participant for an existing chat', () async {
    await repository.ensureChat(
      appointmentId: 'appointment-1',
      currentUserId: 'user-1',
      therapistId: 'therapist-1',
      providerUid: 'provider-1',
    );

    final result = await repository.ensureChat(
      appointmentId: 'appointment-1',
      currentUserId: 'attacker',
      therapistId: 'therapist-1',
      providerUid: 'provider-1',
    );

    expect(result.isFailure, isTrue);
  });

  test('trims messages and streams them in chronological order', () async {
    final first = MessageModel(
      id: '',
      senderId: 'user-1',
      senderAlias: 'QuietRiver',
      text: '  First message  ',
      createdAt: DateTime.utc(2026, 7, 31, 17),
    );
    final second = MessageModel(
      id: '',
      senderId: 'provider-1',
      senderAlias: 'Dr. Aline',
      text: 'Second message',
      createdAt: DateTime.utc(2026, 7, 31, 18),
    );

    expect(
      (await repository.sendMessage(chatId: 'appointment-1', message: first))
          .isSuccess,
      isTrue,
    );
    await Future<void>.delayed(const Duration(milliseconds: 2));
    expect(
      (await repository.sendMessage(chatId: 'appointment-1', message: second))
          .isSuccess,
      isTrue,
    );

    final messages = await repository
        .messagesStream('appointment-1')
        .firstWhere((items) => items.length == 2);
    expect(messages.map((message) => message.text), [
      'First message',
      'Second message',
    ]);
  });

  test('marks only messages from the other participant as read', () async {
    final messages = firestore
        .collection('chats')
        .doc('appointment-1')
        .collection('messages');
    await messages.doc('mine').set({
      'senderId': 'user-1',
      'senderAlias': 'QuietRiver',
      'text': 'Mine',
      'createdAt': DateTime.utc(2026, 7, 31, 17),
      'isRead': false,
    });
    await messages.doc('theirs').set({
      'senderId': 'provider-1',
      'senderAlias': 'Dr. Aline',
      'text': 'Theirs',
      'createdAt': DateTime.utc(2026, 7, 31, 18),
      'isRead': false,
    });

    final result = await repository.markAsRead(
      chatId: 'appointment-1',
      currentUserId: 'user-1',
    );

    expect(result.isSuccess, isTrue);
    expect((await messages.doc('mine').get()).data()?['isRead'], isFalse);
    expect((await messages.doc('theirs').get()).data()?['isRead'], isTrue);
  });

  test('rejects blank and oversized messages before writing', () async {
    MessageModel message(String text) => MessageModel(
          id: '',
          senderId: 'user-1',
          senderAlias: 'QuietRiver',
          text: text,
          createdAt: DateTime.now(),
        );

    expect(
      (await repository.sendMessage(
        chatId: 'appointment-1',
        message: message('   '),
      ))
          .isFailure,
      isTrue,
    );
    expect(
      (await repository.sendMessage(
        chatId: 'appointment-1',
        message: message(List.filled(2001, 'x').join()),
      ))
          .isFailure,
      isTrue,
    );
  });
}
