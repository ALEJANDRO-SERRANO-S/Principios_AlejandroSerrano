import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';

/// Caso de uso para login
/// Cumple con SRP: solo encapsula la lógica de autenticación
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<UserEntity> call(String username, String password) {
    return repository.login(username, password);
  }
}

/// Caso de uso para registro
/// Cumple con SRP: solo encapsula la lógica de registro
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<UserEntity> call(String username, String email, String password) {
    return repository.register(username, email, password);
  }
}

/// Caso de uso para obtener token
class GetTokenUseCase {
  final AuthRepository repository;

  GetTokenUseCase({required this.repository});

  Future<String?> call() {
    return repository.getToken();
  }
}

/// Caso de uso para logout
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  Future<void> call() {
    return repository.logout();
  }
}

/// Caso de uso para verificar autenticación
class IsAuthenticatedUseCase {
  final AuthRepository repository;

  IsAuthenticatedUseCase({required this.repository});

  Future<bool> call() {
    return repository.isAuthenticated();
  }
}

