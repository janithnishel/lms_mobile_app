// lms_app/core/errors/exceptions.dart (Example content)

class ServerException implements Exception {
  final String message;
  final int statusCode;
  const ServerException({required this.message, required this.statusCode});
}

class CacheException implements Exception {}
// ... Other exceptions

class UnknownException implements Exception {
  final String message;
  const UnknownException({required this.message});
}