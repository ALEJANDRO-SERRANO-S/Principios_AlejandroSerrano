import '../entities/entities.dart';

/// Repositorio abstracto para campeones
/// Cumple con ISP: interfaz segregada solo para campeones
/// Cumple con DIP: depender de abstracciones, no de implementaciones
abstract class ChampionRepository {
  Future<List<ChampionEntity>> getChampions();
  Future<void> addChampion(ChampionEntity champion);
  Future<void> deleteChampion(int id);
}

