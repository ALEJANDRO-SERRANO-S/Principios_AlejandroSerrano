import '../entities/entities.dart';

/// Repositorio abstracto para autenticación
/// Cumple con ISP: interfaz segregada solo para autenticación
/// Cumple con DIP: depender de abstracciones, no de implementaciones
abstract class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<String?> getToken();
  Future<void> logout();
  Future<bool> isAuthenticated();
}

