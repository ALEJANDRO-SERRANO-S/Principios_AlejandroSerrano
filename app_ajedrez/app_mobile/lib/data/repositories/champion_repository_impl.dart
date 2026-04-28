import '../../domain/entities/entities.dart';
import '../../domain/repositories/champion_repository.dart';
import '../datasources/champion_remote_datasource.dart';

/// Implementación del repositorio de campeones
/// Cumple con SRP: coordina la fuente de datos remota
/// Cumple con OCP: puede extenderse sin modificarse
class ChampionRepositoryImpl implements ChampionRepository {
  final ChampionRemoteDataSource remoteDataSource;
  final Future<String?> Function() getToken; // Inyección de dependencia para obtener token

  ChampionRepositoryImpl({
    required this.remoteDataSource,
    required this.getToken,
  });

  @override
  Future<List<ChampionEntity>> getChampions() async {
    return await remoteDataSource.getChampions();
  }

  @override
  Future<void> addChampion(ChampionEntity champion) async {
    // Obtener token para autorización
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No autorizado: token no encontrado');
    }

    await remoteDataSource.addChampion(champion, token);
  }

  @override
  Future<void> deleteChampion(int id) async {
    // Obtener token para autorización
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No autorizado: token no encontrado');
    }

    await remoteDataSource.deleteChampion(id, token);
  }
}

