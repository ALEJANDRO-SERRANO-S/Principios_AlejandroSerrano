import '../../domain/entities/entities.dart';
import '../../domain/repositories/champion_repository.dart';

/// Caso de uso para obtener todos los campeones
/// Cumple con SRP: solo encapsula la lógica de obtención
class GetChampionsUseCase {
  final ChampionRepository repository;

  GetChampionsUseCase({required this.repository});

  Future<List<ChampionEntity>> call() {
    return repository.getChampions();
  }
}

/// Caso de uso para agregar un campeón
/// Cumple con SRP: solo encapsula la lógica de adición
class AddChampionUseCase {
  final ChampionRepository repository;

  AddChampionUseCase({required this.repository});

  Future<void> call(ChampionEntity champion) {
    return repository.addChampion(champion);
  }
}

/// Caso de uso para eliminar un campeón
/// Cumple con SRP: solo encapsula la lógica de eliminación
class DeleteChampionUseCase {
  final ChampionRepository repository;

  DeleteChampionUseCase({required this.repository});

  Future<void> call(int id) {
    return repository.deleteChampion(id);
  }
}

