import 'package:equatable/equatable.dart';

sealed class CircleEvent extends Equatable {
  const CircleEvent();

  @override
  List<Object?> get props => [];
}

class CirclesRequested extends CircleEvent {
  final bool refresh;

  const CirclesRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class CircleCategoryChanged extends CircleEvent {
  final String? category;

  const CircleCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class CircleTabChanged extends CircleEvent {
  final bool myCirclesOnly;

  const CircleTabChanged(this.myCirclesOnly);

  @override
  List<Object?> get props => [myCirclesOnly];
}


class CircleJoinToggled extends CircleEvent {
  final String circleId;

  const CircleJoinToggled(this.circleId);

  @override
  List<Object?> get props => [circleId];
}
