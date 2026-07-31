import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failure.dart';
import '../../../../core/utils/result.dart';
import '../models/message_model.dart';

/// Manages appointment-scoped conversations and their message streams.
class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _chats.doc(chatId).collection('messages');

  Future<Result<void>> ensureChat({
    required String appointmentId,
    required String currentUserId,
    required String therapistId,
    required String providerUid,
  }) async {
    if (appointmentId.isEmpty || providerUid.isEmpty) {
      return const ResultError(
        ServerFailure('This professional is not available for chat yet.'),
      );
    }

    try {
      final reference = _chats.doc(appointmentId);
      final existing = await reference.get();
      if (existing.exists) {
        final data = existing.data() ?? const <String, dynamic>{};
        final matchesAppointment = data['appointmentId'] == appointmentId;
        final matchesUser = data['userId'] == currentUserId;
        final matchesTherapist = data['therapistId'] == therapistId;
        final matchesProvider = data['providerUid'] == providerUid;
        if (!matchesAppointment ||
            !matchesUser ||
            !matchesTherapist ||
            !matchesProvider) {
          return const ResultError(
            AuthFailure('You do not have access to this conversation.'),
          );
        }
        return const Success(null);
      }

      await reference.set({
        'appointmentId': appointmentId,
        'userId': currentUserId,
        'therapistId': therapistId,
        'providerUid': providerUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not open this conversation.'),
      );
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  /// Real-time stream of messages ordered by creation time.
  Stream<List<MessageModel>> messagesStream(String cId) {
    return _messages(cId)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(MessageModel.fromDoc)
              .toList()
              .reversed
              .toList(),
        );
  }

  /// Sends a new message. Returns a [Result] so the BLoC can handle errors.
  Future<Result<void>> sendMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    final text = message.text.trim();
    if (text.isEmpty || text.length > 2000) {
      return const ResultError(
        ServerFailure('Messages must contain between 1 and 2000 characters.'),
      );
    }

    try {
      await _messages(chatId).add({
        ...message.toMap(),
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return ResultError(ServerFailure(
          e.message ?? 'Could not send message. Please try again.'));
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  /// Marks all messages NOT sent by [currentUserId] as read.
  Future<Result<void>> markAsRead({
    required String chatId,
    required String currentUserId,
  }) async {
    try {
      final unread = await _messages(chatId)
          .where('isRead', isEqualTo: false)
          .limit(200)
          .get();
      final batch = _firestore.batch();
      for (final doc in unread.docs) {
        if (doc.data()['senderId'] != currentUserId) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      await batch.commit();
      return const Success(null);
    } on FirebaseException catch (error) {
      return ResultError(
        ServerFailure(error.message ?? 'Could not update message receipts.'),
      );
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }
}
