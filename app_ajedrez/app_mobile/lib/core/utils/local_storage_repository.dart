import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/app_exceptions.dart';

/// Abstracción para almacenamiento local
/// Cumple con ISP: interfaz mínima y especializada
abstract class LocalStorageRepository {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Implementación de almacenamiento local con SharedPreferences
/// Cumple con SRP: solo maneja persistencia local
class LocalStorageRepositoryImpl implements LocalStorageRepository {
  late final SharedPreferences _prefs;

  /// Inicializa la instancia de SharedPreferences
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw AppGeneralException(
        message: 'No se pudo inicializar almacenamiento local',
      );
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw AppGeneralException(
        message: 'Error al leer del almacenamiento local',
      );
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw AppGeneralException(
        message: 'Error al escribir en almacenamiento local',
      );
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw AppGeneralException(
        message: 'Error al eliminar del almacenamiento local',
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw AppGeneralException(
        message: 'Error al limpiar almacenamiento local',
      );
    }
  }
}

