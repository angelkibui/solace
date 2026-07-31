import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failure.dart';
import '../../../../core/utils/result.dart';
import '../models/message_model.dart';

/// Manages the `chats/{chatId}/messages` subcollection.
///
/// Chat ID convention: the two UIDs joined in sorted order so both sides
/// always resolve to the same document:
///   `[uid1, uid2]..sort()  → "${sorted[0]}_${sorted[1]}"`
///
/// This keeps the implementation simple for an academic prototype.
/// Production would use a dedicated chat service.
class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static String chatId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  CollectionReference<Map<String, dynamic>> _messages(String cId) =>
      _firestore.collection('chats').doc(cId).collection('messages');

  /// Real-time stream of messages ordered by creation time.
  Stream<List<MessageModel>> messagesStream(String cId) {
    return _messages(cId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(MessageModel.fromDoc).toList());
  }

  /// Sends a new message. Returns a [Result] so the BLoC can handle errors.
  Future<Result<void>> sendMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    try {
      await _messages(chatId).add(message.toMap());
      return const Success(null);
    } on FirebaseException catch (e) {
      return ResultError(
          ServerFailure(e.message ?? 'Could not send message. Please try again.'));
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  /// Marks all messages NOT sent by [currentUserId] as read.
  Future<void> markAsRead({
    required String chatId,
    required String currentUserId,
  }) async {
    try {
      final unread = await _messages(chatId)
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _firestore.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {
      // Non-critical; silently ignore.
    }
  }
}
