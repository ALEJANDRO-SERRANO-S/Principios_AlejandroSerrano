import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Estado de autenticación
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider de autenticación con ChangeNotifier
/// Cumple con SRP: solo maneja estado de autenticación
/// Cumple con OCP: puede extenderse sin modificarse
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final IsAuthenticatedUseCase _isAuthenticatedUseCase;

  AuthState _state = AuthState.initial;
  UserEntity? _user;
  String? _errorMessage;

  AuthProvider({
    LoginUseCase? loginUseCase,
    RegisterUseCase? registerUseCase,
    LogoutUseCase? logoutUseCase,
    IsAuthenticatedUseCase? isAuthenticatedUseCase,
  })  : _loginUseCase = loginUseCase ?? ServiceLocator.get(),
        _registerUseCase = registerUseCase ?? ServiceLocator.get(),
        _logoutUseCase = logoutUseCase ?? ServiceLocator.get(),
        _isAuthenticatedUseCase = isAuthenticatedUseCase ?? ServiceLocator.get() {
    _checkAuthentication();
  }

  // Getters
  AuthState get state => _state;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Verifica si el usuario está autenticado
  Future<void> _checkAuthentication() async {
    try {
      final isAuth = await _isAuthenticatedUseCase();
      if (isAuth) {
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = _extractErrorMessage(e);
    }
    notifyListeners();
  }

  /// Inicia sesión
  Future<bool> login(String username, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _loginUseCase(username, password);
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Registra un nuevo usuario
  Future<bool> register(String username, String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _registerUseCase(username, email, password);
      _state = AuthState.unauthenticated; // Usuario debe hacer login
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    try {
      await _logoutUseCase();
      _user = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
    }
  }

  /// Extrae mensaje de error
  String _extractErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }
}

