import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, inProgress, completed }

class OnboardingState extends Equatable {
  final Set<String> selectedConcerns;
  final OnboardingStatus status;

  /// The anonymous alias picked/shuffled on WelcomeScreen (Part C5). Carried
  /// through onboarding so Register (Part D10) can pre-fill it instead of
  /// asking the user to make the same identity decision twice.
  final String? alias;

  const OnboardingState({
    this.selectedConcerns = const {},
    this.status = OnboardingStatus.initial,
    this.alias,
  });

  OnboardingState copyWith({
    Set<String>? selectedConcerns,
    OnboardingStatus? status,
    String? alias,
  }) {
    return OnboardingState(
      selectedConcerns: selectedConcerns ?? this.selectedConcerns,
      status: status ?? this.status,
      alias: alias ?? this.alias,
    );
  }

  @override
  List<Object?> get props => [selectedConcerns, status, alias];
}
