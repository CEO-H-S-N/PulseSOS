/// Base failure class for error handling across the app
abstract class Failure {
  final String message;
  final int? code;
  const Failure({required this.message, this.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message, super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class SOSThrottleFailure extends Failure {
  final Duration cooldownRemaining;
  const SOSThrottleFailure({
    required super.message,
    required this.cooldownRemaining,
    super.code,
  });
}
