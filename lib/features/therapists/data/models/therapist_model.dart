import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TherapistModel extends Equatable {
  final String id;
  final String name;
  final String title;
  final List<String> specialties;
  final List<String> languages;
  final int rate;
  final String bio;
  final String photoUrl;
  final double rating;
  final int reviewCount;
  final String location;
  final String gender;
  final String providerUid;
  final List<DateTime> availability;

  const TherapistModel({
    required this.id,
    required this.name,
    required this.title,
    required this.specialties,
    required this.languages,
    required this.rate,
    required this.bio,
    required this.photoUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.gender,
    this.providerUid = '',
    required this.availability,
  });

  factory TherapistModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return TherapistModel.fromMap(document.data() ?? const {}, document.id);
  }

  factory TherapistModel.fromMap(Map<String, dynamic> map, String id) {
    final rawAvailability = map['availability'] as List? ?? const [];
    return TherapistModel(
      id: id,
      name: map['name'] as String? ?? 'Solace Professional',
      title: map['title'] as String? ?? 'Licensed Counselor',
      specialties: List<String>.from(map['specialties'] as List? ?? const []),
      languages: List<String>.from(map['languages'] as List? ?? const []),
      rate: (map['rate'] as num?)?.round() ?? 0,
      bio: map['bio'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.round() ?? 0,
      location: map['location'] as String? ?? 'Kigali, Rwanda',
      gender: map['gender'] as String? ?? 'Not specified',
      providerUid: map['providerUid'] as String? ?? '',
      availability: rawAvailability
          .whereType<Timestamp>()
          .map((timestamp) => timestamp.toDate())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'specialties': specialties,
      'languages': languages,
      'rate': rate,
      'bio': bio,
      'photoUrl': photoUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location,
      'gender': gender,
      'providerUid': providerUid,
      'availability': availability.map(Timestamp.fromDate).toList(),
    };
  }

  TherapistModel copyWith({
    String? id,
    String? name,
    String? title,
    List<String>? specialties,
    List<String>? languages,
    int? rate,
    String? bio,
    String? photoUrl,
    double? rating,
    int? reviewCount,
    String? location,
    String? gender,
    String? providerUid,
    List<DateTime>? availability,
  }) {
    return TherapistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      specialties: specialties ?? this.specialties,
      languages: languages ?? this.languages,
      rate: rate ?? this.rate,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      providerUid: providerUid ?? this.providerUid,
      availability: availability ?? this.availability,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        specialties,
        languages,
        rate,
        bio,
        photoUrl,
        rating,
        reviewCount,
        location,
        gender,
        providerUid,
        availability,
      ];
}
