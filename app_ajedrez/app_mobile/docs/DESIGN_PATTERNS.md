# Patrones de Diseño Implementados

Este documento describe los patrones de diseño utilizados en el proyecto Chess App Mobile.

---

## 1. **Repository Pattern**

### Propósito
Abstrae el acceso a datos, permitiendo cambiar la fuente de datos sin afectar la lógica de negocio.

### Estructura
```
Repository (Interfaz)
    ↓
    ├── RepositoryImpl (HTTP)
    ├── RepositoryCached (HTTP + Caché)
    └── RepositoryMock (Testing)
```

### Implementación en el Proyecto

#### Interfaz (Domain Layer)
```dart
abstract class ChampionRepository {
  Future<List<ChampionEntity>> getChampions();
  Future<void> addChampion(ChampionEntity champion);
  Future<void> deleteChampion(int id);
}

abstract class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<String?> getToken();
  Future<void> logout();
}
```

#### Implementación (Data Layer)
```dart
class ChampionRepositoryImpl implements ChampionRepository {
  final ChampionRemoteDataSource remoteDataSource;
  
  ChampionRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<List<ChampionEntity>> getChampions() async {
    return await remoteDataSource.getChampions();
  }
}
```

#### Uso (Domain Layer)
```dart
class GetChampionsUseCase {
  final ChampionRepository repository;
  
  GetChampionsUseCase({required this.repository});
  
  Future<List<ChampionEntity>> call() {
    return repository.getChampions(); // No importa la implementación
  }
}
```

### Ventajas
✅ Cambiar datasource sin afectar capas superiores  
✅ Testing con mocks  
✅ Múltiples implementaciones paralelas  

---

## 2. **Data Source Pattern**

### Propósito
Separa la obtención de datos del procesamiento. Cada DataSource maneja UN tipo de fuente.

### Estructura
```
ChampionRepository
    ↓
    ├── ChampionRemoteDataSource (HTTP)
    ├── ChampionLocalDataSource (SQLite/Hive) ← futuro
    └── ChampionMemoryDataSource (Mock)
```

### Implementación en el Proyecto

```dart
// Interfaz segregada
abstract class ChampionRemoteDataSource {
  Future<List<ChampionEntity>> getChampions();
  Future<void> addChampion(ChampionEntity champion, String token);
  Future<void> deleteChampion(int id, String token);
}

// Implementación HTTP
class ChampionRemoteDataSourceImpl implements ChampionRemoteDataSource {
  final http.Client httpClient;
  
  ChampionRemoteDataSourceImpl({required this.httpClient});
  
  @override
  Future<List<ChampionEntity>> getChampions() async {
    final response = await httpClient.get(Uri.parse(baseUrl));
    return _parseResponse(response);
  }
}

// En el futuro, agregar sin modificar nada:
class ChampionLocalDataSourceImpl implements ChampionRemoteDataSource {
  final DatabaseRepository db;
  // Implementar métodos...
}
```

### Ventajas
✅ Responsabilidad clara: un DataSource = una fuente  
✅ Fácil agregar nuevas fuentes (caché, BD local, etc)  
✅ Testing de HTTP sin afectar lógica de negocio  

---

## 3. **Use Case Pattern**

### Propósito
Encapsula un caso de uso de negocio específico. Cada UseCase = una acción del usuario.

### Estructura
```
UseCase
  ↓
  uses: Repository
  ↓
  returns: Entity o void
```

### Implementación en el Proyecto

```dart
// Caso de uso simple
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase({required this.repository});
  
  // call() es la convención para casos de uso
  Future<UserEntity> call(String username, String password) {
    return repository.login(username, password);
  }
}

// Caso de uso con transformación
class DeleteChampionUseCase {
  final ChampionRepository repository;
  
  DeleteChampionUseCase({required this.repository});
  
  Future<void> call(int id) async {
    // Lógica adicional si es necesaria (validación, etc)
    if (id <= 0) {
      throw ValidationException(message: 'ID inválido');
    }
    await repository.deleteChampion(id);
  }
}
```

### Ventajas
✅ Lógica de negocio separada de UI y datos  
✅ Fácil testear lógica sin UI  
✅ Reutilizable desde diferentes UIs  

---

## 4. **Service Locator Pattern**

### Propósito
Centralizar la creación y registro de instancias (inyección de dependencias).

### Implementación en el Proyecto

```dart
class ServiceLocator {
  static final _instance = GetIt.instance;
  
  static Future<void> setupServiceLocator() async {
    // Nivel 1: Utilidades base
    _instance.registerSingleton<http.Client>(http.Client());
    _instance.registerSingleton<LocalStorageRepository>(
      LocalStorageRepositoryImpl()..initialize(),
    );
    
    // Nivel 2: Data Sources
    _instance.registerSingleton<AuthRemoteDataSource>(
      AuthRemoteDataSource(httpClient: _instance<http.Client>()),
    );
    
    // Nivel 3: Repositories
    _instance.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(
        remoteDataSource: _instance<AuthRemoteDataSource>(),
        localStorageRepository: _instance<LocalStorageRepository>(),
      ),
    );
    
    // Nivel 4: Use Cases
    _instance.registerSingleton<LoginUseCase>(
      LoginUseCase(repository: _instance<AuthRepository>()),
    );
    
    // Nivel 5: Providers
    _instance.registerSingleton<AuthProvider>(
      AuthProvider(loginUseCase: _instance<LoginUseCase>()),
    );
  }
  
  static T get<T extends Object>() => _instance<T>();
}
```

### Uso
```dart
// En main.dart
void main() async {
  await ServiceLocator.setupServiceLocator();
  runApp(const ChessApp());
}

// En providers
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  
  AuthProvider({LoginUseCase? loginUseCase})
    : _loginUseCase = loginUseCase ?? ServiceLocator.get();
}

// En testing
setUp(() {
  ServiceLocator.reset();
  // Registrar mocks
  ServiceLocator.setupServiceLocator(); // con mocks
});
```

### Ventajas
✅ Punto único de configuración  
✅ Fácil cambiar implementaciones  
✅ Testeable (inyectar mocks)  
✅ Evita constructor hell  

---

## 5. **Singleton Pattern**

### Propósito
Garantizar que haya SOLO una instancia de un objeto durante la vida de la app.

### Implementación en el Proyecto

```dart
// GetIt usa Singleton automáticamente
_instance.registerSingleton<http.Client>(http.Client());
// Solo habrá un http.Client en toda la app

// Acceso desde cualquier lugar
final httpClient = ServiceLocator.get<http.Client>();
final httpClient2 = ServiceLocator.get<http.Client>();
// httpClient === httpClient2 (misma instancia)
```

### Ventajas
✅ Recursos compartidos eficientemente  
✅ Estado persistente (tokens, datos cacheados)  
✅ Evita múltiples conexiones innecesarias  

---

## 6. **Observer Pattern (Provider)**

### Propósito
Notificar múltiples widgets cuando el estado cambia.

### Implementación en el Proyecto

```dart
// Observable (Subject)
class AuthProvider extends ChangeNotifier {
  String? _user;
  
  String? get user => _user;
  
  void setUser(String user) {
    _user = user;
    notifyListeners(); // Notifica a todos los observadores
  }
}

// Observadores (Listeners)
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text('Usuario: ${authProvider.user}');
  },
)

// El widget se reconstruye automáticamente cuando cambia el estado
```

### Ventajas
✅ Actualización automática de UI  
✅ Desacoplamiento entre widgets  
✅ Reactividad sin boilerplate  

---

## 7. **Builder Pattern**

### Propósito
Permitir construir objetos complejos paso a paso.

### Implementación en el Proyecto

#### Factory Method en Entidad
```dart
class ChampionEntity {
  factory ChampionEntity.fromJson(Map<String, dynamic> json) {
    return ChampionEntity(
      id: json['id'],
      name: json['name'],
      // ... más campos
    );
  }
}
```

#### Consumer Builder en UI
```dart
Consumer<ChampionProvider>(
  builder: (context, championProvider, _) {
    if (championProvider.isLoading) {
      return CircularProgressIndicator();
    }
    if (championProvider.isEmpty) {
      return Text('Sin datos');
    }
    return ListView(
      children: championProvider.champions.map((c) => ...).toList(),
    );
  },
)
```

### Ventajas
✅ Construcción clara de objetos  
✅ UI condicional sin nesting profundo  
✅ Legibilidad mejorada  

---

## 8. **Factory Pattern**

### Propósito
Crear objetos sin especificar clases concretas exactas.

### Implementación en el Proyecto

```dart
// Métodos factory en entidades
class ChampionEntity {
  // Factory constructor
  factory ChampionEntity.fromChampion(Champion champion) {
    return ChampionEntity(
      id: champion.id,
      name: champion.name,
      // ... conversión
    );
  }
  
  // Factory con valores por defecto
  factory ChampionEntity.empty() {
    return ChampionEntity(
      id: null,
      name: '',
      birthCountry: '',
      representedCountry: '',
      ageAtFirstWin: 0,
      period: '',
      imageUrl: '',
      bio: '',
    );
  }
}

// Uso
final empty = ChampionEntity.empty();
final from = ChampionEntity.fromChampion(championModel);
```

### Ventajas
✅ Creación clara y semantica  
✅ Encapsulación de lógica de creación  
✅ Fácil cambiar construcción sin afectar usuarios  

---

## 9. **Adapter Pattern (Implícito)**

### Propósito
Adaptar una interfaz a otra esperada.

### Implementación en el Proyecto

```dart
// RemoteDataSource adapta http.Response a ChampionEntity
class ChampionRemoteDataSourceImpl {
  Future<List<ChampionEntity>> getChampions() async {
    final response = await httpClient.get(uri);
    
    // Adaptación: Response → List<ChampionEntity>
    return response.statusCode == 200
      ? _parseChampions(response)
      : throw ServerException();
  }
}
```

### Ventajas
✅ Compatibilidad entre sistemas diferentes  
✅ Cambiar estructura sin afectar consumidores  

---

## 10. **Strategy Pattern**

### Propósito
Definir una familia de algoritmos intercambiables.

### Implementación Futura

```dart
// Interfaces para estrategias de persistencia
abstract class StorageStrategy {
  Future<List<ChampionEntity>> get();
  Future<void> save(ChampionEntity champion);
}

// Estrategia 1: HTTP
class HttpStorageStrategy implements StorageStrategy {
  @override
  Future<List<ChampionEntity>> get() => remoteDataSource.getChampions();
}

// Estrategia 2: SQLite
class SqliteStorageStrategy implements StorageStrategy {
  @override
  Future<List<ChampionEntity>> get() => localDataSource.getChampions();
}

// Estrategia 3: Hybrid
class HybridStorageStrategy implements StorageStrategy {
  @override
  Future<List<ChampionEntity>> get() async {
    try {
      return await httpStrategy.get(); // Intentar remoto
    } catch (e) {
      return await sqliteStrategy.get(); // Fallback a local
    }
  }
}

// Uso
class ChampionRepository {
  final StorageStrategy _strategy;
  
  ChampionRepository({required StorageStrategy strategy})
    : _strategy = strategy;
  
  Future<List<ChampionEntity>> getChampions() {
    return _strategy.get(); // Delegar a estrategia
  }
}
```

### Ventajas
✅ Intercambiar comportamientos en runtime  
✅ Nueva lógica sin modificar clases existentes  

---

## **Tabla Resumen de Patrones**

| Patrón | Ubicación | Propósito |
|--------|-----------|----------|
| **Repository** | domain/ + data/ | Abstracción de datos |
| **Data Source** | data/datasources/ | Separación de fuentes |
| **Use Case** | domain/usecases/ | Encapsular lógica |
| **Service Locator** | core/di/ | Inyección de dependencias |
| **Singleton** | GetIt | Instancia única |
| **Observer** | presentation/providers/ | Notificación de cambios |
| **Builder** | presentation/ | Construcción de UI |
| **Factory** | domain/entities/ | Creación de objetos |
| **Adapter** | data/datasources/ | Compatibilidad |
| **Strategy** | Futuro | Algoritmos intercambiables |

---

## **Combinación de Patrones**

El proyecto combina estos patrones de forma armónica:

```
Presentation Layer (Observer + Builder)
        ↓
Domain Layer (Use Case)
        ↓
Data Layer (Repository + Data Source + Factory)
        ↓
Core Layer (Service Locator + Singleton)
```

Cada capa usa los patrones más apropiados para sus responsabilidades.

---

## **Referencias**

- [Gang of Four - Design Patterns](https://en.wikipedia.org/wiki/Design_Patterns)
- [Repository Pattern - Microsoft](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design)
- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

