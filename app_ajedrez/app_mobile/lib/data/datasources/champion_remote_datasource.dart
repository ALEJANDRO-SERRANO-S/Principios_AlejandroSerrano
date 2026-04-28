import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/http_helper.dart';
import '../../domain/entities/entities.dart';

/// Fuente de datos remota para campeones
/// Cumple con SRP: solo se encarga de comunicación HTTP
abstract class ChampionRemoteDataSource {
  Future<List<ChampionEntity>> getChampions();
  Future<void> addChampion(ChampionEntity champion, String token);
  Future<void> deleteChampion(int id, String token);
}

/// Implementación de fuente de datos remota para campeones
class ChampionRemoteDataSourceImpl implements ChampionRemoteDataSource {
  static const String baseUrl = 'https://api-ajedrez.onrender.com/api/champions';
  final http.Client httpClient;

  ChampionRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<ChampionEntity>> getChampions() async {
    try {
      final response = await httpClient.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = HttpHelper.parseJsonListResponse(response);
        return decoded
            .map((model) => ChampionEntity(
                  id: _toInt(model['id']),
                  name: model['name']?.toString() ?? '',
                  birthCountry: model['birthCountry']?.toString() ?? '',
                  representedCountry: model['representedCountry']?.toString() ?? '',
                  ageAtFirstWin: _toInt(model['ageAtFirstWin']) ?? 0,
                  period: model['period']?.toString() ?? '',
                  imageUrl: model['imageUrl']?.toString() ?? '',
                  bio: model['bio']?.toString() ?? '',
                ))
            .toList();
      } else {
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<void> addChampion(ChampionEntity champion, String token) async {
    try {
      final response = await httpClient.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': champion.name,
          'birthCountry': champion.birthCountry,
          'representedCountry': champion.representedCountry,
          'ageAtFirstWin': champion.ageAtFirstWin,
          'period': champion.period,
          'imageUrl': champion.imageUrl,
          'bio': champion.bio,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<void> deleteChampion(int id, String token) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// Convierte dinámicamente a int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class ErrorHandler {
  static AppException handleException(dynamic exception) {
    if (exception is AppException) return exception;
    return AppGeneralException(message: exception.toString());
  }

  static AppException handleHttpError(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      return AuthException(message: 'No autorizado (${response.statusCode})');
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

