import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, inProgress, completed }

class OnboardingState extends Equatable {
  final Set<String> selectedConcerns;
  final OnboardingStatus status;

  const OnboardingState({
    this.selectedConcerns = const {},
    this.status = OnboardingStatus.initial,
  });

  OnboardingState copyWith({
    Set<String>? selectedConcerns,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      selectedConcerns: selectedConcerns ?? this.selectedConcerns,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [selectedConcerns, status];
}