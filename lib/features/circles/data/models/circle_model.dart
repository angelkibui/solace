import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CircleModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final int memberCount;
  final bool isModerated;
  final String moderatorName;
  final DateTime createdAt;
  final String imageUrl;

  /// UIDs of members who have joined. Not itemized in the task sheet's
  /// field list (I1), but needed to actually implement "My Circles" (I8)
  /// and join/leave (I5) without a second collection — [memberCount] is
  /// kept as its own field (rather than derived via memberIds.length) so
  /// it can be shown without reading/counting the array client-side, same
  /// as TherapistModel keeps reviewCount separate from the reviews
  /// themselves.
  final List<String> memberIds;

  const CircleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberCount,
    required this.isModerated,
    required this.moderatorName,
    required this.createdAt,
    required this.imageUrl,
    this.memberIds = const [],
  });

  bool isJoinedBy(String userId) => memberIds.contains(userId);

  factory CircleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return CircleModel.fromMap(document.data() ?? const {}, document.id);
  }

  factory CircleModel.fromMap(Map<String, dynamic> map, String id) {
    final rawCreatedAt = map['createdAt'];
    return CircleModel(
      id: id,
      name: map['name'] as String? ?? 'Unnamed Circle',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      memberCount: (map['memberCount'] as num?)?.round() ?? 0,
      isModerated: map['isModerated'] as bool? ?? true,
      moderatorName: map['moderatorName'] as String? ?? 'Solace Team',
      createdAt:
          rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : DateTime.now(),
      imageUrl: map['imageUrl'] as String? ?? '',
      memberIds: List<String>.from(map['memberIds'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'memberCount': memberCount,
      'isModerated': isModerated,
      'moderatorName': moderatorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'memberIds': memberIds,
    };
  }

  CircleModel copyWith({
    String? name,
    String? description,
    String? category,
    int? memberCount,
    bool? isModerated,
    String? moderatorName,
    String? imageUrl,
    List<String>? memberIds,
  }) {
    return CircleModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      memberCount: memberCount ?? this.memberCount,
      isModerated: isModerated ?? this.isModerated,
      moderatorName: moderatorName ?? this.moderatorName,
      createdAt: createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        memberCount,
        isModerated,
        moderatorName,
        createdAt,
        imageUrl,
        memberIds,
      ];
}
