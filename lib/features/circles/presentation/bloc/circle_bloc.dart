import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/repositories/circle_repository.dart';
import 'circle_event.dart';
import 'circle_state.dart';

class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final CircleRepository _repository;

  CircleBloc(this._repository, {required String userId})
      : super(CircleState(userId: userId)) {
    on<CirclesRequested>(_onCirclesRequested);
    on<CircleCategoryChanged>(_onCategoryChanged);
    on<CircleTabChanged>(_onTabChanged);
    on<CircleJoinToggled>(_onJoinToggled);
  }

  Future<void> _onCirclesRequested(
    CirclesRequested event,
    Emitter<CircleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: event.refresh ? CircleStatus.refreshing : CircleStatus.loading,
        clearError: true,
      ),
    );
    final result = await _repository.getCircles();
    switch (result) {
      case Success(data: final circles):
        emit(state.copyWith(status: CircleStatus.success, circles: circles));
      case ResultError(failure: final failure):
        emit(
          state.copyWith(
            status: CircleStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  void _onCategoryChanged(
    CircleCategoryChanged event,
    Emitter<CircleState> emit,
  ) {
    emit(
      state.copyWith(
        category: event.category,
        clearCategory: event.category == null,
      ),
    );
  }

  void _onTabChanged(CircleTabChanged event, Emitter<CircleState> emit) {
    emit(state.copyWith(myCirclesOnly: event.myCirclesOnly));
  }

  Future<void> _onJoinToggled(
    CircleJoinToggled event,
    Emitter<CircleState> emit,
  ) async {
    if (state.pendingCircleIds.contains(event.circleId)) return;
    final index = state.circles.indexWhere((c) => c.id == event.circleId);
    if (index == -1) return;
    final circle = state.circles[index];
    final isJoined = circle.isJoinedBy(state.userId);

    emit(
      state.copyWith(
        pendingCircleIds: {...state.pendingCircleIds, event.circleId},
        clearError: true,
      ),
    );

    final result = isJoined
        ? await _repository.leaveCircle(event.circleId, state.userId)
        : await _repository.joinCircle(event.circleId, state.userId);

    final stillPending = {...state.pendingCircleIds}..remove(event.circleId);

    switch (result) {
      case Success():
        final latestIndex =
            state.circles.indexWhere((item) => item.id == event.circleId);
        if (latestIndex == -1) {
          emit(state.copyWith(pendingCircleIds: stillPending));
          return;
        }
        final latestCircle = state.circles[latestIndex];
        final membershipAlreadyApplied =
            latestCircle.isJoinedBy(state.userId) != isJoined;
        if (membershipAlreadyApplied) {
          emit(state.copyWith(pendingCircleIds: stillPending));
          return;
        }
        final updatedMemberIds = isJoined
            ? (List<String>.from(latestCircle.memberIds)..remove(state.userId))
            : [...latestCircle.memberIds, state.userId];
        final updatedCircles = [...state.circles];
        updatedCircles[latestIndex] = latestCircle.copyWith(
          memberIds: updatedMemberIds,
          memberCount: latestCircle.memberCount + (isJoined ? -1 : 1),
        );
        emit(
          state.copyWith(
            circles: updatedCircles,
            pendingCircleIds: stillPending,
          ),
        );
      case ResultError(failure: final failure):
        emit(
          state.copyWith(
            pendingCircleIds: stillPending,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
