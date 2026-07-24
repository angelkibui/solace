import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/shared_prefs_service.dart';
import 'onboarding_state.dart';

/// Tracks which concern chips are selected on the "What's on your mind
/// today?" screen, and whether onboarding has been completed before (so
/// SplashScreen can skip straight past it on relaunch — see C7).
class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPrefsService _prefsService;

  OnboardingCubit(this._prefsService) : super(const OnboardingState());

  void toggleConcern(String concern) {
    final updated = Set<String>.from(state.selectedConcerns);
    if (updated.contains(concern)) {
      updated.remove(concern);
    } else {
      updated.add(concern);
    }
    emit(state.copyWith(selectedConcerns: updated, status: OnboardingStatus.inProgress));
  }

  /// Called once by SplashScreen on app launch to decide whether to show
  /// onboarding again or skip straight to the app.
  Future<bool> hasCompletedOnboarding() => _prefsService.getOnboardingComplete();

  Future<void> completeOnboarding() async {
    await _prefsService.setOnboardingComplete(true);
    emit(state.copyWith(status: OnboardingStatus.completed));
  }
}