import '../../core/utils/local_storage_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
/// Cumple con SRP: coordina local storage + remote datasource
/// Cumple con OCP: puede extenderse sin modificarse (agregar caché, etc)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageRepository localStorageRepository;

  // Constante para la clave del token
  static const String _tokenKey = 'jwt_token';

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorageRepository,
  });

  @override
  Future<UserEntity> login(String username, String password) async {
    // 1. Obtener token del servidor
    final token = await remoteDataSource.login(username, password);

    // 2. Guardar token localmente
    await localStorageRepository.setString(_tokenKey, token);

    // 3. Retornar usuario con token
    return UserEntity(
      username: username,
      email: '', // No disponible en respuesta actual
      token: token,
      roles: const ['user'],
    );
  }

  @override
  Future<UserEntity> register(String username, String email, String password) async {
    // 1. Registrar en servidor
    await remoteDataSource.register(username, email, password);

    // 2. El servidor no retorna token en registro, usuario debe hacer login después
    // Por simplicidad, retornamos un usuario temporal
    return UserEntity(
      username: username,
      email: email,
      token: '',
      roles: const ['user'],
    );
  }

  @override
  Future<String?> getToken() async {
    return await localStorageRepository.getString(_tokenKey);
  }

  @override
  Future<void> logout() async {
    await localStorageRepository.remove(_tokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

