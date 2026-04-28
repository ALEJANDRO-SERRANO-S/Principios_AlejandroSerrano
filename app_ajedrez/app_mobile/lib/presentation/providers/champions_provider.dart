import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/champion_usecases.dart';

/// Estado de carga de campeones
enum ChampionLoadState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider de campeones con ChangeNotifier
/// Cumple con SRP: solo maneja estado de campeones
/// Cumple con OCP: puede extenderse sin modificarse
class ChampionProvider extends ChangeNotifier {
  final GetChampionsUseCase _getChampionsUseCase;
  final AddChampionUseCase _addChampionUseCase;
  final DeleteChampionUseCase _deleteChampionUseCase;

  ChampionLoadState _state = ChampionLoadState.initial;
  List<ChampionEntity> _champions = [];
  String? _errorMessage;

  ChampionProvider({
    GetChampionsUseCase? getChampionsUseCase,
    AddChampionUseCase? addChampionUseCase,
    DeleteChampionUseCase? deleteChampionUseCase,
  })  : _getChampionsUseCase = getChampionsUseCase ?? ServiceLocator.get(),
        _addChampionUseCase = addChampionUseCase ?? ServiceLocator.get(),
        _deleteChampionUseCase = deleteChampionUseCase ?? ServiceLocator.get();

  // Getters
  ChampionLoadState get state => _state;
  List<ChampionEntity> get champions => List.unmodifiable(_champions);
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ChampionLoadState.loading;
  bool get isEmpty => _champions.isEmpty;
  int get count => _champions.length;

  /// Carga todos los campeones
  Future<void> loadChampions() async {
    _state = ChampionLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _champions = await _getChampionsUseCase();
      _state = ChampionLoadState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = ChampionLoadState.error;
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
    }
  }

  /// Añade un nuevo campeón
  Future<bool> addChampion(ChampionEntity champion) async {
    try {
      await _addChampionUseCase(champion);
      // Recargar lista después de agregar
      await loadChampions();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Elimina un campeón
  Future<bool> deleteChampion(int id) async {
    try {
      await _deleteChampionUseCase(id);
      // Eliminar localmente
      _champions.removeWhere((champion) => champion.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Obtiene un campeón por ID
  ChampionEntity? getChampionById(int id) {
    try {
      return _champions.firstWhere((champion) => champion.id == id);
    } catch (e) {
      return null;
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

