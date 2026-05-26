/// Custom exceptions for data layer
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException({required this.message, this.code});
}

class LocationException implements Exception {
  final String message;
  const LocationException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection'});
}
