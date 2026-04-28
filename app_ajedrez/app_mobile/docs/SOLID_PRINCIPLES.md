# Principios SOLID - Chess App Mobile

Este documento detalla cómo el proyecto implementa cada uno de los 5 principios SOLID.

---

## **S - Single Responsibility Principle (SRP)**

### Definición
*"Una clase debe tener una única razón para cambiar"*

### Aplicación en el Proyecto

#### ❌ **ANTES** (Violación de SRP)
```dart
class ChampionService {
  // Responsabilidad 1: Comunicación HTTP
  Future<List<Champion>> getChampions() async { }
  
  // Responsabilidad 2: Parsing JSON
  // (Lógica inline)
  
  // Responsabilidad 3: Manejo de tokens
  Future<Map<String, String>> _getAuthHeaders() async { }
  
  // Responsabilidad 4: Manejo de errores
  String _extractResponseMessage(http.Response response) { }
}
```

#### ✅ **DESPUÉS** (Aplicando SRP)

1. **HttpHelper**: Solo maneja respuestas HTTP
```dart
class HttpHelper {
  static Map<String, dynamic> parseJsonResponse(http.Response response) { }
  static String extractMessage(http.Response response) { }
}
```

2. **ChampionRemoteDataSource**: Solo comunicación HTTP
```dart
class ChampionRemoteDataSourceImpl implements ChampionRemoteDataSource {
  Future<List<ChampionEntity>> getChampions() async { }
  Future<void> addChampion(ChampionEntity champion, String token) async { }
}
```

3. **ChampionRepositoryImpl**: Solo coordina datasource + token
```dart
class ChampionRepositoryImpl implements ChampionRepository {
  Future<List<ChampionEntity>> getChampions() async {
    return await remoteDataSource.getChampions();
  }
}
```

4. **ChampionProvider**: Solo gestión de estado
```dart
class ChampionProvider extends ChangeNotifier {
  Future<void> loadChampions() async {
    _state = ChampionLoadState.loading;
    _champions = await _getChampionsUseCase();
  }
}
```

### Beneficios Logrados
- ✅ Cada clase tiene una única responsabilidad clara
- ✅ Cambios en parsing HTTP no afectan lógica de autenticación
- ✅ Fácil testear cada componente de forma aislada
- ✅ Código más legible y mantenible

---

## **O - Open/Closed Principle (OCP)**

### Definición
*"Las entidades de software deben estar abiertas para extensión pero cerradas para modificación"*

### Aplicación en el Proyecto

#### ❌ **ANTES** (Violación de OCP)
```dart
class ChampionService {
  // Única forma de obtener datos: HTTP
  Future<List<Champion>> getChampions() async {
    final response = await http.get(uri);
    // ... parseo
  }
  
  // Para agregar caché, ¡hay que modificar esta clase!
}
```

#### ✅ **DESPUÉS** (Aplicando OCP)

1. **Interfaz de repositorio** (abierta a extensión):
```dart
abstract class ChampionRepository {
  Future<List<ChampionEntity>> getChampions();
  Future<void> addChampion(ChampionEntity champion);
  Future<void> deleteChampion(int id);
}
```

2. **Implementación HTTP** (cerrada a modificación):
```dart
class ChampionRepositoryImpl implements ChampionRepository {
  // Implementación actual
}
```

3. **Implementación con caché** (extensión futura sin modificar):
```dart
class ChampionRepositoryCachedImpl implements ChampionRepository {
  final ChampionRemoteDataSource remoteDataSource;
  final CacheRepository cacheRepository;
  
  Future<List<ChampionEntity>> getChampions() async {
    // Primero intenta caché
    final cached = await cacheRepository.getChampions();
    if (cached != null) return cached;
    
    // Si no hay caché, obtener de remoto
    final remote = await remoteDataSource.getChampions();
    await cacheRepository.saveChampions(remote);
    return remote;
  }
}
```

4. **Uso en Service Locator** (intercambiable):
```dart
// Versión actual
_instance.registerSingleton<ChampionRepository>(
  ChampionRepositoryImpl(...)
);

// Versión futura (sin cambiar nada más)
_instance.registerSingleton<ChampionRepository>(
  ChampionRepositoryCachedImpl(...)
);
```

### Beneficios Logrados
- ✅ Agregar caché local sin modificar código existente
- ✅ Cambiar de API HTTP a GraphQL sin afectar capas superiores
- ✅ Tests pueden inyectar mock sin modificar producción
- ✅ Nuevas datasources se agregan por composición

---

## **L - Liskov Substitution Principle (LSP)**

### Definición
*"Los objetos de una clase derivada deben poder usarse donde se espera la clase base"*

### Aplicación en el Proyecto

#### Repositorios Intercambiables
```dart
// Contrato
abstract class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<void> logout();
}

// Implementación 1: HTTP
class AuthRepositoryImpl implements AuthRepository {
  Future<UserEntity> login(String username, String password) async {
    // Obtener token del servidor
  }
}

// Implementación 2: Mock para testing
class AuthRepositoryMock implements AuthRepository {
  Future<UserEntity> login(String username, String password) async {
    // Simular login
    return UserEntity(username: username, email: '', token: 'mock_token');
  }
}

// Implementación 3: Offline
class AuthRepositoryOffline implements AuthRepository {
  Future<UserEntity> login(String username, String password) async {
    // Usar credenciales locales
  }
}
```

#### Uso Polimórfico
```dart
// El provider no sabe (ni le importa) cuál implementación está usando
class AuthProvider {
  final AuthRepository _repository; // Puede ser cualquier implementación
  
  AuthProvider({required AuthRepository repository})
    : _repository = repository;
  
  Future<bool> login(String username, String password) async {
    _user = await _repository.login(username, password);
    // ... resto del código
  }
}

// En producción
ServiceLocator.get<AuthRepository>() // → AuthRepositoryImpl

// En testing
mockAuthProvider = AuthProvider(repository: AuthRepositoryMock())

// Offline
offlineAuthProvider = AuthProvider(repository: AuthRepositoryOffline())
```

### Beneficios Logrados
- ✅ Cualquier implementación de AuthRepository es válida
- ✅ Testing fácil con mocks
- ✅ Código desacoplado de implementaciones específicas
- ✅ Estrategias intercambiables en runtime

---

## **I - Interface Segregation Principle (ISP)**

### Definición
*"Los clientes no deben depender de interfaces que no usan"*

### Aplicación en el Proyecto

#### ❌ **ANTES** (Violación de ISP)
```dart
// Una mega-interfaz que hace todo
abstract class DataService {
  Future<List<Champion>> getChampions();
  Future<void> addChampion(Champion champion);
  Future<void> deleteChampion(int id);
  
  Future<bool> login(String username, String password);
  Future<bool> register(String username, String email, String password);
  Future<void> logout();
  Future<String?> getToken();
  
  // ChampionProvider solo necesita los 3 primeros métodos
  // AuthProvider solo necesita los 4 últimos
  // ¡Pero ambos están acoplados a toda la interfaz!
}
```

#### ✅ **DESPUÉS** (Aplicando ISP)

1. **Interfaz segregada para autenticación**:
```dart
abstract class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<String?> getToken();
  Future<void> logout();
  Future<bool> isAuthenticated();
}
```

2. **Interfaz segregada para campeones**:
```dart
abstract class ChampionRepository {
  Future<List<ChampionEntity>> getChampions();
  Future<void> addChampion(ChampionEntity champion);
  Future<void> deleteChampion(int id);
}
```

3. **Interfaz segregada para almacenamiento**:
```dart
abstract class LocalStorageRepository {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}
```

#### Uso en Providers
```dart
// AuthProvider solo depende de lo que necesita
class AuthProvider {
  final AuthRepository _repository;
  final LocalStorageRepository _storage;
  // Solo le importan estos 2 interfaces
}

// ChampionProvider solo depende de lo que necesita
class ChampionProvider {
  final ChampionRepository _repository;
  // Solo le importa esta interfaz
}
```

### Beneficios Logrados
- ✅ Cada interface es pequeña y enfocada
- ✅ Las clases solo dependen de métodos que realmente usan
- ✅ Cambios en auth no afectan a champions
- ✅ Fácil entender dependencias de cada componente

---

## **D - Dependency Inversion Principle (DIP)**

### Definición
*"Las clases de alto nivel no deben depender de clases de bajo nivel. Ambas deben depender de abstracciones"*

### Aplicación en el Proyecto

#### ❌ **ANTES** (Violación de DIP)
```dart
class ChampionDetailScreen extends StatelessWidget {
  // Alto acoplamiento a implementación concreta
  final ChampionService _service = ChampionService();
  
  void _delete() {
    _service.deleteChampion(id); // Directamente acoplado
  }
}

// El flujo es: Screen → Service → HTTP
// Screen depende de implementación concreta
```

#### ✅ **DESPUÉS** (Aplicando DIP)

1. **Inyección de dependencia en constructor**:
```dart
class ChampionDetailScreen extends StatelessWidget {
  final ChampionEntity champion;
  // NO crea instancias, las recibe inyectadas
  
  const ChampionDetailScreen({
    required this.champion,
  });
  
  void _delete(BuildContext context, ChampionProvider provider) {
    provider.deleteChampion(champion.id!);
  }
}
```

2. **Uso de interfaces en vez de implementaciones**:
```dart
// En Data Layer
class ChampionRepositoryImpl implements ChampionRepository {
  final ChampionRemoteDataSource remoteDataSource; // Inyectado
  
  ChampionRepositoryImpl({required this.remoteDataSource});
}

// En Domain Layer
class DeleteChampionUseCase {
  final ChampionRepository repository; // Depende de interfaz
  
  DeleteChampionUseCase({required this.repository});
}

// En Presentation Layer
class ChampionProvider {
  final DeleteChampionUseCase deleteChampionUseCase; // Inyectado
  
  ChampionProvider({required this.deleteChampionUseCase});
}
```

3. **Configuración centralizada en Service Locator**:
```dart
// La configuración de dependencias está en UN SOLO LUGAR
class ServiceLocator {
  static Future<void> setupServiceLocator() async {
    // Nivel 1
    _instance.registerSingleton<http.Client>(http.Client());
    
    // Nivel 2
    _instance.registerSingleton<ChampionRemoteDataSource>(
      ChampionRemoteDataSourceImpl(httpClient: _instance<http.Client>()),
    );
    
    // Nivel 3
    _instance.registerSingleton<ChampionRepository>(
      ChampionRepositoryImpl(
        remoteDataSource: _instance<ChampionRemoteDataSource>(),
      ),
    );
    
    // Nivel 4
    _instance.registerSingleton<DeleteChampionUseCase>(
      DeleteChampionUseCase(
        repository: _instance<ChampionRepository>(),
      ),
    );
    
    // Nivel 5
    _instance.registerSingleton<ChampionProvider>(
      ChampionProvider(
        deleteChampionUseCase: _instance<DeleteChampionUseCase>(),
      ),
    );
  }
}
```

#### Flujo de Dependencias Invertido
```
Producción:
main.dart
  ↓
ServiceLocator.setupServiceLocator()
  ↓
[HTTP Client → RemoteDataSource → Repository → UseCase → Provider → Screen]

Testing:
TestMain.dart
  ↓
ServiceLocator.setupServiceLocator() // con mocks
  ↓
[MockHttpClient → MockDataSource → MockRepository → MockUseCase → Provider → Screen]

⚠️ ¡El screen NO cambia en ninguno de los casos!
```

### Beneficios Logrados
- ✅ Desacoplamiento total entre capas
- ✅ Fácil hacer testing con mocks
- ✅ Cambiar implementaciones sin modificar código
- ✅ Inyección de dependencias explícita y clara
- ✅ Testing unitario sin necesidad de Flutter

---

## **Resumen de Implementación SOLID**

| Principio | Implementación | Archivo(s) Clave |
|-----------|-----------------|------------------|
| **S** | Responsabilidad única por clase | DataSource, Repository, Provider, UseCase |
| **O** | Interfaz → Implementación | Abstract classes en domain/ |
| **L** | Polimorfismo correcto | Mock implementations possible |
| **I** | Interfaces segregadas | AuthRepository, ChampionRepository, LocalStorageRepository |
| **D** | Service Locator + Interfaces | core/di/service_locator.dart |

---

## **Checklist de SOLID**

- [x] Cada clase tiene UNA responsabilidad
- [x] Nuevas features se agregan por extensión, no modificación
- [x] Cualquier implementación de interfaz es válida
- [x] Interfaces pequeñas y focalizadas
- [x] Bajo nivel depende de abstracciones del alto nivel
- [x] Dependencias inyectadas, no instanciadas
- [x] Testing fácil con mocks

---

## **Próximos Pasos para Mejorar**

1. **Agregar caché local** (Hive/SQLite)
   - Crear `LocalDataSource` que implemente `ChampionRepository`
   - Registrar en Service Locator

2. **Agregar logging** 
   - Crear interfaz `Logger`
   - Inyectar en repositorios

3. **Manejo de errores mejorado**
   - Más excepciones específicas
   - Recovery strategies

4. **Testing completo**
   - Unit tests para Use Cases
   - Widget tests para Screens
   - Mock repositories

---

## **Referencias**

- [SOLID Principles - Robert C. Martin](https://en.wikipedia.org/wiki/SOLID)
- [Clean Code - Robert C. Martin](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
- [Architecture Patterns with Python](https://www.cosmicpython.com/)

