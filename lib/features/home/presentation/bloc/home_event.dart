import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once when HomeScreen first mounts.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// E7 — pull-to-refresh.
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}
