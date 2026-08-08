final class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Something went wrong on the server.']);
}

final class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection.']);
}

final class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'No cached data available.']);
}

final class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'The requested item was not found.']);
}
