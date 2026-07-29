import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum AppointmentStatus { pendingPayment, confirmed, completed, cancelled }

enum SessionType { individual, couples, group }

extension AppointmentStatusX on AppointmentStatus {
  String get value => switch (this) {
        AppointmentStatus.pendingPayment => 'pending_payment',
        AppointmentStatus.confirmed => 'confirmed',
        AppointmentStatus.completed => 'completed',
        AppointmentStatus.cancelled => 'cancelled',
      };

  String get label => switch (this) {
        AppointmentStatus.pendingPayment => 'Payment pending',
        AppointmentStatus.confirmed => 'Confirmed',
        AppointmentStatus.completed => 'Completed',
        AppointmentStatus.cancelled => 'Cancelled',
      };

  static AppointmentStatus fromValue(String? value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AppointmentStatus.pendingPayment,
    );
  }
}

extension SessionTypeX on SessionType {
  String get value => name;

  String get label => switch (this) {
        SessionType.individual => 'Individual',
        SessionType.couples => 'Couples',
        SessionType.group => 'Group',
      };

  String get description => switch (this) {
        SessionType.individual => 'Private one-on-one support',
        SessionType.couples => 'A shared session for two people',
        SessionType.group => 'Guided support with a small group',
      };

  static SessionType fromValue(String? value) {
    return SessionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SessionType.individual,
    );
  }
}

class AppointmentModel extends Equatable {
  final String id;
  final String userId;
  final String therapistId;
  final DateTime dateTime;
  final SessionType sessionType;
  final AppointmentStatus status;
  final int amount;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.id,
    required this.userId,
    required this.therapistId,
    required this.dateTime,
    required this.sessionType,
    required this.status,
    required this.amount,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final map = document.data() ?? const <String, dynamic>{};
    final createdAt = map['createdAt'];
    final updatedAt = map['updatedAt'];
    final dateTime = map['dateTime'];
    return AppointmentModel(
      id: document.id,
      userId: map['userId'] as String? ?? '',
      therapistId: map['therapistId'] as String? ?? '',
      dateTime: dateTime is Timestamp ? dateTime.toDate() : DateTime.now(),
      sessionType: SessionTypeX.fromValue(map['sessionType'] as String?),
      status: AppointmentStatusX.fromValue(map['status'] as String?),
      amount: (map['amount'] as num?)?.round() ?? 0,
      notes: map['notes'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'therapistId': therapistId,
      'dateTime': Timestamp.fromDate(dateTime),
      'sessionType': sessionType.value,
      'status': status.value,
      'amount': amount,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? therapistId,
    DateTime? dateTime,
    SessionType? sessionType,
    AppointmentStatus? status,
    int? amount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      therapistId: therapistId ?? this.therapistId,
      dateTime: dateTime ?? this.dateTime,
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        therapistId,
        dateTime,
        sessionType,
        status,
        amount,
        notes,
        createdAt,
        updatedAt,
      ];
}
