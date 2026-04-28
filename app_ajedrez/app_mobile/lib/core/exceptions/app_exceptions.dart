/// Excepción base de la aplicación
/// Cumple con SRP: solo define la jerarquía de excepciones
abstract class AppException implements Exception {
  final String message;
  final String code;

  AppException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Excepción de autenticación
class AuthException extends AppException {
  AuthException({
    required String message,
    String code = 'AUTH_ERROR',
  }) : super(message: message, code: code);
}

/// Excepción de red/conexión
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String code = 'NETWORK_ERROR',
  }) : super(message: message, code: code);
}

/// Excepción de servidor
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    required String message,
    String code = 'SERVER_ERROR',
    this.statusCode,
  }) : super(message: message, code: code);
}

/// Excepción de validación
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String code = 'VALIDATION_ERROR',
  }) : super(message: message, code: code);
}

/// Excepción genérica de aplicación
class AppGeneralException extends AppException {
  AppGeneralException({
    required String message,
    String code = 'GENERAL_ERROR',
  }) : super(message: message, code: code);
}

