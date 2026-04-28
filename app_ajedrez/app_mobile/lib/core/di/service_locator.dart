import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/local_storage_repository.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/champion_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/champion_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/champion_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/champion_usecases.dart';

/// Service Locator para inyección de dependencias
/// Cumple con DIP: centraliza la creación de instancias
/// Cumple con SRP: solo se encarga de configurar dependencias
class ServiceLocator {
  static final _instance = GetIt.instance;

  /// Registra todas las dependencias
  static Future<void> setupServiceLocator() async {
    // 1. Inicializar almacenamiento local
    final localStorage = LocalStorageRepositoryImpl();
    await localStorage.initialize();
    _instance.registerSingleton<LocalStorageRepository>(localStorage);

    // 2. Registrar HTTP client
    _instance.registerSingleton<http.Client>(http.Client());

    // 3. Registrar data sources (nivel bajo)
    _instance.registerSingleton<AuthRemoteDataSource>(
      AuthRemoteDataSource(httpClient: _instance<http.Client>()),
    );

    _instance.registerSingleton<ChampionRemoteDataSource>(
      ChampionRemoteDataSourceImpl(httpClient: _instance<http.Client>()),
    );

    // 4. Registrar repositorios (nivel intermedio)
    _instance.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(
        remoteDataSource: _instance<AuthRemoteDataSource>(),
        localStorageRepository: _instance<LocalStorageRepository>(),
      ),
    );

    _instance.registerSingleton<ChampionRepository>(
      ChampionRepositoryImpl(
        remoteDataSource: _instance<ChampionRemoteDataSource>(),
        getToken: () => _instance<AuthRepository>().getToken(),
      ),
    );

    // 5. Registrar use cases (nivel alto)
    _instance.registerSingleton<LoginUseCase>(
      LoginUseCase(repository: _instance<AuthRepository>()),
    );

    _instance.registerSingleton<RegisterUseCase>(
      RegisterUseCase(repository: _instance<AuthRepository>()),
    );

    _instance.registerSingleton<GetTokenUseCase>(
      GetTokenUseCase(repository: _instance<AuthRepository>()),
    );

    _instance.registerSingleton<LogoutUseCase>(
      LogoutUseCase(repository: _instance<AuthRepository>()),
    );

    _instance.registerSingleton<IsAuthenticatedUseCase>(
      IsAuthenticatedUseCase(repository: _instance<AuthRepository>()),
    );

    _instance.registerSingleton<GetChampionsUseCase>(
      GetChampionsUseCase(repository: _instance<ChampionRepository>()),
    );

    _instance.registerSingleton<AddChampionUseCase>(
      AddChampionUseCase(repository: _instance<ChampionRepository>()),
    );

    _instance.registerSingleton<DeleteChampionUseCase>(
      DeleteChampionUseCase(repository: _instance<ChampionRepository>()),
    );
  }

  /// Obtiene una instancia registrada
  static T get<T extends Object>() {
    return _instance<T>();
  }

  /// Limpia todas las instancias (útil para testing)
  static void reset() {
    _instance.reset();
  }
}

