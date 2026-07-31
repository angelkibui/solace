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

/// I3 — category chip selection. null means "All Circles".
class CircleCategoryChanged extends CircleEvent {
  final String? category;

  const CircleCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

/// I2/I8 — toggles between the "All Circles" and "My Circles" tabs.
class CircleTabChanged extends CircleEvent {
  final bool myCirclesOnly;

  const CircleTabChanged(this.myCirclesOnly);

  @override
  List<Object?> get props => [myCirclesOnly];
}

/// I5 — join if not currently a member, leave if already one. Whether
/// it's a join or a leave is decided in CircleBloc from the circle's
/// current memberIds, not passed in here, so callers (the card, the
/// detail screen) don't need to duplicate that check themselves.
class CircleJoinToggled extends CircleEvent {
  final String circleId;

  const CircleJoinToggled(this.circleId);

  @override
  List<Object?> get props => [circleId];
}
