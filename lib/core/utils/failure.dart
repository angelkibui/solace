import 'package:equatable/equatable.dart';

/// Base class for all recoverable errors in the app.
///
/// Every layer (data, domain, presentation) should convert raw exceptions
/// (FirebaseException, SocketException, etc.) into a [Failure] before it
/// crosses into a Bloc/Cubit. This keeps UI code free of try/catch blocks
/// around vendor-specific exception types.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

/// Something went wrong on Firestore / Firebase's side.
class ServerFailure extends Failure {
  const ServerFailure(
      [super.message =
          'Something went wrong on the server. Please try again.']);
}

/// Reading/writing local data (SharedPreferences, cache) failed.
class CacheFailure extends Failure {
  const CacheFailure(
      [super.message = 'Could not load saved data on this device.']);
}

/// No internet connection, or a request timed out.
class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message =
          'No internet connection. Check your network and try again.']);
}

/// Login, registration, or session errors.
class AuthFailure extends Failure {
  const AuthFailure(
      [super.message = 'Authentication failed. Please try again.']);
}

/// User-entered data did not pass validation.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Catch-all for anything unexpected.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something unexpected happened.']);
}
