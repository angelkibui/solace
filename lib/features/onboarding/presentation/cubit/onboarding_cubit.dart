import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/shared_prefs_service.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPrefsService _prefsService;

  OnboardingCubit(this._prefsService) : super(const OnboardingState());

 
  void setAlias(String alias) {
    emit(state.copyWith(alias: alias));
  }

  void toggleConcern(String concern) {
    final updated = Set<String>.from(state.selectedConcerns);
    if (updated.contains(concern)) {
      updated.remove(concern);
    } else {
      updated.add(concern);
    }
    emit(state.copyWith(
        selectedConcerns: updated, status: OnboardingStatus.inProgress));
  }


  Future<bool> hasCompletedOnboarding() =>
      _prefsService.getOnboardingComplete();

  Future<void> completeOnboarding() async {
    await _prefsService.setOnboardingComplete(true);
    emit(state.copyWith(status: OnboardingStatus.completed));
  }
}
