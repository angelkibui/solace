import 'failure.dart';

/// A lightweight "either" type: every repository method should return a
/// [Result] instead of throwing, so Blocs/Cubits can pattern-match on
/// success/failure without wrapping every call in try/catch.
///
/// Usage:
/// ```dart
/// Future<Result<UserModel>> getUser(String uid) async {
///   try {
///     final doc = await _firestore.collection('users').doc(uid).get();
///     return Success(UserModel.fromMap(doc.data()!));
///   } on FirebaseException catch (e) {
///     return ResultError(ServerFailure(e.message ?? 'Failed to load user.'));
///   }
/// }
///
/// final result = await repo.getUser(uid);
/// result.fold(
///   (failure) => emit(state.copyWith(error: failure.message)),
///   (user) => emit(state.copyWith(user: user)),
/// );
/// ```
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class ResultError<T> extends Result<T> {
  final Failure failure;
  const ResultError(this.failure);
}

extension ResultX<T> on Result<T> {
  /// Collapses the result into a single value by handling both branches.
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    return switch (this) {
      Success<T>(data: final data) => onSuccess(data),
      ResultError<T>(failure: final failure) => onFailure(failure),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultError<T>;

  /// Returns the data if this is a [Success], otherwise null.
  T? get dataOrNull => switch (this) {
        Success<T>(data: final data) => data,
        ResultError<T>() => null,
      };
}
