import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/http_helper.dart';

/// Fuente de datos remota para autenticación
/// Cumple con SRP: solo se encarga de comunicación HTTP
/// Cumple con DIP: depende de abstracciones (interfaces de http)
class AuthRemoteDataSource {
  final String baseUrl = 'https://api-ajedrez.onrender.com/api/auth';
  final http.Client httpClient;

  AuthRemoteDataSource({required this.httpClient});

  /// Inicia sesión y retorna el token
  Future<String> login(String username, String password) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = HttpHelper.parseJsonResponse(response);
        final token = data['accessToken'] as String?;
        if (token == null) {
          throw ValidationException(message: 'Token no encontrado en respuesta');
        }
        return token;
      } else {
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// Registra un nuevo usuario
  Future<void> register(String username, String email, String password) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': ['user'],
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}

