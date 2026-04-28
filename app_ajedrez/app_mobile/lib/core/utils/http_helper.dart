import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/app_exceptions.dart';

/// Utilidad para manejo de respuestas HTTP
/// Cumple con SRP: solo convierte respuestas HTTP a datos o excepciones
class HttpHelper {
  static Map<String, dynamic> parseJsonResponse(http.Response response) {
    try {
      if (response.body.isEmpty) return {};
      return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Error al procesar respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }

  static List<dynamic> parseJsonListResponse(http.Response response) {
    try {
      if (response.body.isEmpty) return [];
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is! List) {
        throw ValidationException(
          message: 'Respuesta inesperada: se esperaba una lista',
        );
      }
      return decoded;
    } catch (e) {
      throw ServerException(
        message: 'Error al procesar respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }

  static String extractMessage(http.Response response) {
    try {
      final data = parseJsonResponse(response);
      return data['message']?.toString() ?? response.body;
    } catch (_) {
      return response.body;
    }
  }
}

/// Utilidad para manejo de errores HTTP
class ErrorHandler {
  static AppException handleException(dynamic exception) {
    if (exception is AppException) return exception;

    if (exception is http.ClientException) {
      return NetworkException(
        message: 'Error de conexión: ${exception.message}',
      );
    }

    return AppGeneralException(
      message: exception.toString(),
    );
  }

  static AppException handleHttpError(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      return AuthException(
        message: 'No autorizado (${response.statusCode})',
      );
    }

    if (response.statusCode >= 500) {
      return ServerException(
        message: 'Error del servidor: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    return ServerException(
      message: HttpHelper.extractMessage(response),
      statusCode: response.statusCode,
    );
  }
}

