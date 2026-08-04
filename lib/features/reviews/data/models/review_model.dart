import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String therapistId;
  final String clientId;
  final String clientName;
  final int rating; // 1-5
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isVerifiedSession; // Client booked & completed session

  const ReviewModel({
    required this.id,
    required this.therapistId,
    required this.clientId,
    required this.clientName,
    required this.rating,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isVerifiedSession = false,
  });

  factory ReviewModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ReviewModel(
      id: doc.id,
      therapistId: data['therapistId'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerifiedSession: data['isVerifiedSession'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'therapistId': therapistId,
      'clientId': clientId,
      'clientName': clientName,
      'rating': rating,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerifiedSession': isVerifiedSession,
    };
  }

  @override
  List<Object?> get props => [
    id,
    therapistId,
    clientId,
    rating,
    title,
    content,
    createdAt,
    isVerifiedSession,
  ];
}