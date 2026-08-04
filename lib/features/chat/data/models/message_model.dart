import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a single message inside a chat room.
/// Firestore path: chats/{chatId}/messages/{messageId}
class MessageModel extends Equatable {
  final String id;
  final String senderId;
  final String senderAlias;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderAlias,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderAlias: data['senderAlias'] as String? ?? 'Anonymous',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderAlias': senderAlias,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderAlias,
        text,
        createdAt,
        isRead,
      ];
}
class TypingIndicator extends Equatable {
  final String userId;
  final String userName;
  final DateTime timestamp;

  const TypingIndicator({
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  factory TypingIndicator.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TypingIndicator(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Someone',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  @override
  List<Object?> get props => [userId, userName, timestamp];
}
