import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://api-ajedrez.onrender.com/api/auth';

  // 1. INICIAR SESIÓN (Obtener el gafete)
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Si las credenciales son correctas, el servidor nos devuelve datos
        final data = json.decode(utf8.decode(response.bodyBytes));
        final String token = data['accessToken']; // Aquí viene nuestro Token JWT

        // Guardamos el token en la "caja fuerte" (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        return true;
      } else {
        // Contraseña incorrecta o usuario no existe
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 2. REGISTRARSE
  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
            'username': username,
            'email': email,
            'password': password,
            'role': ['user'] // Por defecto asignamos el rol de usuario normal
        }),
      );

      // El servidor devuelve 200 OK si se guardó con éxito
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. LEER EL TOKEN (Para usarlo después al crear Campeones)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // 4. CERRAR SESIÓN (Bota el gafete a la basura)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}

