class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException(super.message) : super(statusCode: null);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Sesi habis, silakan login ulang', statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

class ServerException extends AppException {
  const ServerException(super.message) : super(statusCode: 500);
}
