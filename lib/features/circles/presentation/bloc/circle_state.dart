import 'package:equatable/equatable.dart';

import '../../data/models/circle_model.dart';

enum CircleStatus { initial, loading, success, failure, refreshing }

class CircleState extends Equatable {
  final CircleStatus status;
  final List<CircleModel> circles;
  final String userId;
  final String? category;
  final bool myCirclesOnly;
  final String? errorMessage;

  final Set<String> pendingCircleIds;

  const CircleState({
    this.status = CircleStatus.initial,
    this.circles = const [],
    this.userId = '',
    this.category,
    this.myCirclesOnly = false,
    this.errorMessage,
    this.pendingCircleIds = const {},
  });

  List<CircleModel> get visibleCircles {
    return circles.where((circle) {
      final matchesCategory = category == null || circle.category == category;
      final matchesTab = !myCirclesOnly || circle.isJoinedBy(userId);
      return matchesCategory && matchesTab;
    }).toList();
  }

  List<String> get availableCategories =>
      circles.map((c) => c.category).toSet().toList()..sort();

  CircleState copyWith({
    CircleStatus? status,
    List<CircleModel>? circles,
    String? userId,
    String? category,
    bool? myCirclesOnly,
    String? errorMessage,
    Set<String>? pendingCircleIds,
    bool clearCategory = false,
    bool clearError = false,
  }) {
    return CircleState(
      status: status ?? this.status,
      circles: circles ?? this.circles,
      userId: userId ?? this.userId,
      category: clearCategory ? null : category ?? this.category,
      myCirclesOnly: myCirclesOnly ?? this.myCirclesOnly,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingCircleIds: pendingCircleIds ?? this.pendingCircleIds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        circles,
        userId,
        category,
        myCirclesOnly,
        errorMessage,
        pendingCircleIds,
      ];
}
