import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/champion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChampionService {
  // IMPORTANTE: Reemplaza esto con tu URL de Render real
  static const String baseUrl = 'https://api-ajedrez.onrender.com/api/champions';

  // --- NUEVO: Método ayudante para obtener el gafete (Token) ---
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    return {
      'Content-Type': 'application/json',
      // Si hay token guardado, lo pegamos en la cabecera
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _extractResponseMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'sin detalle adicional';
    }

    try {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ?? response.body;
      }
      return response.body;
    } catch (_) {
      return response.body;
    }
  }

  // Método para LEER (GET) todos los campeones (Público/Protegido)
  Future<List<Champion>> getChampions() async {
    try {
      final headers = await _getAuthHeaders(); // <-- ¡1. SACAMOS EL TOKEN!

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers, // <-- ¡2. SE LO PEGAMOS A LA PETICIÓN!
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is! List) {
          throw Exception('Respuesta inesperada del servidor: se esperaba una lista de campeones.');
        }

        return decoded
            .map((model) => Champion.fromJson(Map<String, dynamic>.from(model as Map)))
            .toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado para leer campeones (${response.statusCode}).');
      } else {
        throw Exception(
          'Error del servidor: ${response.statusCode}. ${_extractResponseMessage(response)}',
        );
      }
    } catch (e) {
      throw Exception('Error al cargar campeones: $e');
    }
  }

  // Método para CREAR (POST) un nuevo campeón (Requiere Token)
  Future<void> addChampion(Champion champion) async {
    try {
      final headers = await _getAuthHeaders(); // <-- Obtenemos el token

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers, // <-- Adjuntamos la cabecera de seguridad
        body: json.encode(champion.toJson()),
      );

      // Spring Boot devuelve 200 (OK) o 201 (Created) cuando tiene éxito
      if (response.statusCode != 200 && response.statusCode != 201) {
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception('No autorizado para guardar campeones (${response.statusCode}).');
        }

        throw Exception(
          'Error al guardar en el servidor: ${response.statusCode}. ${_extractResponseMessage(response)}',
        );
      }
    } catch (e) {
      throw Exception('Error al guardar campeón: $e');
    }
  }

  // Método para ELIMINAR (DELETE) un campeón por su ID (Requiere Token de Admin)
  Future<void> deleteChampion(int id) async {
    try {
      final headers = await _getAuthHeaders(); // <-- Obtenemos el token

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers, // <-- Adjuntamos la cabecera de seguridad
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception('No autorizado para eliminar campeones (${response.statusCode}).');
        }

        throw Exception(
          'Error al eliminar en el servidor: ${response.statusCode}. ${_extractResponseMessage(response)}',
        );
      }
    } catch (e) {
      throw Exception('Error al eliminar campeón: $e');
    }
  }
}