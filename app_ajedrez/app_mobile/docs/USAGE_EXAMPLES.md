# Ejemplos de Uso - Chess App Mobile

Ejemplos prácticos de cómo usar la arquitectura en diferentes escenarios.

---

## **1. Flujo de Autenticación**

### Iniciando la App
```dart
// main.dart
void main() async {
  // Configurar todas las dependencias
  await ServiceLocator.setupServiceLocator();
  runApp(const ChessApp());
}
```

### Pantalla de Login
```dart
// login_screen.dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submit(AuthProvider authProvider) async {
    bool success = await authProvider.login(
      _userController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      // AuthWrapper automáticamente navega a ChampionsListScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          body: Column(
            children: [
              TextField(controller: _userController),
              TextField(controller: _passwordController, obscureText: true),
              ElevatedButton(
                onPressed: () => _submit(authProvider),
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Flujo Interno
```
User tapa "Login"
  ↓
_submit() llamado
  ↓
authProvider.login(username, password) [PRESENTATION]
  ↓
LoginUseCase(username, password) [DOMAIN]
  ↓
AuthRepositoryImpl.login(username, password) [DATA]
  ↓
AuthRemoteDataSource.login(username, password) [DATA]
  ↓
http.post('/.../signin', body: {username, password}) [HTTP]
  ↓
Response: {accessToken: "jwt..."}
  ↓
AuthRemoteDataSource retorna token [DATA]
  ↓
AuthRepositoryImpl guarda en SharedPreferences [DATA]
  ↓
AuthRepositoryImpl retorna UserEntity [DATA]
  ↓
LoginUseCase retorna UserEntity [DOMAIN]
  ↓
authProvider.login() = true, _user = UserEntity [PRESENTATION]
  ↓
notifyListeners() → AuthWrapper reconstruye
  ↓
AuthWrapper.isAuthenticated = true → ChampionsListScreen
```

---

## **2. Cargar Lista de Campeones**

### Screen
```dart
// main.dart - ChampionsListScreen
class ChampionsListScreen extends StatefulWidget {
  @override
  State<ChampionsListScreen> createState() => _ChampionsListScreenState();
}

class _ChampionsListScreenState extends State<ChampionsListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar campeones cuando la pantalla se abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChampionProvider>().loadChampions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maestros del Tablero')),
      body: Consumer<ChampionProvider>(
        builder: (context, championProvider, _) {
          if (championProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (championProvider.state == ChampionLoadState.error) {
            return Center(
              child: Text('Error: ${championProvider.errorMessage}'),
            );
          }

          return ListView.builder(
            itemCount: championProvider.count,
            itemBuilder: (context, index) {
              final champion = championProvider.champions[index];
              return ListTile(
                title: Text(champion.name),
                subtitle: Text(champion.period),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Provider
```dart
// presentation/providers/champions_provider.dart
class ChampionProvider extends ChangeNotifier {
  final GetChampionsUseCase _getChampionsUseCase;

  ChampionLoadState _state = ChampionLoadState.initial;
  List<ChampionEntity> _champions = [];

  Future<void> loadChampions() async {
    _state = ChampionLoadState.loading;
    notifyListeners();

    try {
      _champions = await _getChampionsUseCase(); // Llamar use case
      _state = ChampionLoadState.loaded;
    } catch (e) {
      _state = ChampionLoadState.error;
      _errorMessage = _extractErrorMessage(e);
    }
    notifyListeners(); // Notificar cambios
  }
}
```

### Use Case
```dart
// domain/usecases/champion_usecases.dart
class GetChampionsUseCase {
  final ChampionRepository repository;

  GetChampionsUseCase({required this.repository});

  Future<List<ChampionEntity>> call() {
    return repository.getChampions(); // Delegar al repositorio
  }
}
```

### Repository
```dart
// data/repositories/champion_repository_impl.dart
class ChampionRepositoryImpl implements ChampionRepository {
  final ChampionRemoteDataSource remoteDataSource;

  @override
  Future<List<ChampionEntity>> getChampions() async {
    return await remoteDataSource.getChampions(); // Obtener de fuente remota
  }
}
```

### Data Source
```dart
// data/datasources/champion_remote_datasource.dart
class ChampionRemoteDataSourceImpl implements ChampionRemoteDataSource {
  @override
  Future<List<ChampionEntity>> getChampions() async {
    try {
      final response = await httpClient.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final decoded = HttpHelper.parseJsonListResponse(response);
        return decoded.map((json) => ChampionEntity(...)).toList();
      }
      throw ErrorHandler.handleHttpError(response);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
```

---

## **3. Agregar un Nuevo Campeón**

### Formulario
```dart
// screens/champion_form_screen.dart
class _ChampionFormScreenState extends State<ChampionFormScreen> {
  void _saveChampion(ChampionProvider championProvider) async {
    final newChampion = ChampionEntity(
      name: _nameController.text,
      birthCountry: _birthCountryController.text,
      // ... más campos
    );

    bool success = await championProvider.addChampion(newChampion);
    if (success && mounted) {
      Navigator.pop(context, true); // Volver a lista
    }
  }
}
```

### Provider Maneja Lógica
```dart
class ChampionProvider extends ChangeNotifier {
  final AddChampionUseCase _addChampionUseCase;

  Future<bool> addChampion(ChampionEntity champion) async {
    try {
      await _addChampionUseCase(champion);
      // Después de agregar, recargar lista
      await loadChampions();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
}
```

### Use Case Coordina
```dart
class AddChampionUseCase {
  final ChampionRepository repository;

  Future<void> call(ChampionEntity champion) {
    return repository.addChampion(champion);
  }
}
```

### Repository Obtiene Token y Envía
```dart
class ChampionRepositoryImpl implements ChampionRepository {
  final ChampionRemoteDataSource remoteDataSource;
  final Future<String?> Function() getToken;

  @override
  Future<void> addChampion(ChampionEntity champion) async {
    final token = await getToken(); // Obtener token de AuthRepository
    if (token == null) throw Exception('No autorizado');
    
    await remoteDataSource.addChampion(champion, token);
  }
}
```

### Data Source Envía al API
```dart
class ChampionRemoteDataSourceImpl {
  @override
  Future<void> addChampion(ChampionEntity champion, String token) async {
    final response = await httpClient.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': champion.name,
        'birthCountry': champion.birthCountry,
        // ...
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ErrorHandler.handleHttpError(response);
    }
  }
}
```

---

## **4. Eliminar un Campeón**

### Detail Screen
```dart
class ChampionDetailScreen extends StatelessWidget {
  void _confirmDelete(BuildContext context, ChampionProvider championProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                bool success = await championProvider.deleteChampion(champion.id!);
                if (success && context.mounted) {
                  Navigator.pop(context, true); // Volver a lista
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
```

### Provider Maneja Eliminación
```dart
class ChampionProvider extends ChangeNotifier {
  Future<bool> deleteChampion(int id) async {
    try {
      await _deleteChampionUseCase(id); // Use case
      _champions.removeWhere((c) => c.id == id); // Actualizar lista local
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
}
```

### Cadena Completa
```
Provider.deleteChampion(id)
  ↓
DeleteChampionUseCase(id)
  ↓
Repository.deleteChampion(id) + obtener token
  ↓
RemoteDataSource.deleteChampion(id, token)
  ↓
httpClient.delete('/api/champions/$id', headers: Authorization)
  ↓
[OK o Error]
```

---

## **5. Testing con Mocks**

### Mock Repository
```dart
// test/mocks/mock_champion_repository.dart
class MockChampionRepository implements ChampionRepository {
  @override
  Future<List<ChampionEntity>> getChampions() async {
    return [
      ChampionEntity(
        id: 1,
        name: 'Magnus Carlsen',
        birthCountry: 'Noruega',
        representedCountry: 'Noruega',
        ageAtFirstWin: 22,
        period: '2013-presente',
        imageUrl: 'url',
        bio: 'Campeón mundial',
      ),
    ];
  }

  @override
  Future<void> addChampion(ChampionEntity champion) async {}

  @override
  Future<void> deleteChampion(int id) async {}
}
```

### Widget Test
```dart
// test/screens/champions_list_screen_test.dart
void main() {
  testWidgets('ChampionsListScreen carga y muestra campeones', (WidgetTester tester) async {
    // Preparar
    final mockRepository = MockChampionRepository();
    
    // Inyectar
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ChampionProvider(
          getChampionsUseCase: GetChampionsUseCase(
            repository: mockRepository,
          ),
        ),
        child: MaterialApp(
          home: ChampionsListScreen(),
        ),
      ),
    );

    // Esperar carga
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('Magnus Carlsen'), findsOneWidget);
  });
}
```

### Unit Test del UseCase
```dart
// test/domain/usecases/get_champions_usecase_test.dart
void main() {
  group('GetChampionsUseCase', () {
    late GetChampionsUseCase useCase;
    late MockChampionRepository mockRepository;

    setUp(() {
      mockRepository = MockChampionRepository();
      useCase = GetChampionsUseCase(repository: mockRepository);
    });

    test('debe retornar lista de campeones', () async {
      // Actuar
      final result = await useCase();

      // Verificar
      expect(result, isA<List<ChampionEntity>>());
      expect(result.length, greaterThan(0));
      expect(result[0].name, 'Magnus Carlsen');
    });
  });
}
```

---

## **6. Agregar Nueva Funcionalidad (Actualizar Campeón)**

### 1. Domain Layer
```dart
// domain/repositories/champion_repository.dart
abstract class ChampionRepository {
  // Existente...
  
  // Nuevo:
  Future<void> updateChampion(ChampionEntity champion);
}

// domain/usecases/champion_usecases.dart
class UpdateChampionUseCase {
  final ChampionRepository repository;

  UpdateChampionUseCase({required this.repository});

  Future<void> call(ChampionEntity champion) {
    return repository.updateChampion(champion);
  }
}
```

### 2. Data Layer
```dart
// data/datasources/champion_remote_datasource.dart
abstract class ChampionRemoteDataSource {
  // Existente...
  Future<void> updateChampion(ChampionEntity champion, String token);
}

class ChampionRemoteDataSourceImpl {
  @override
  Future<void> updateChampion(ChampionEntity champion, String token) async {
    final response = await httpClient.put(
      Uri.parse('$baseUrl/${champion.id}'),
      headers: {'Authorization': 'Bearer $token'},
      body: json.encode({
        'name': champion.name,
        // ... otros campos
      }),
    );

    if (response.statusCode != 200) {
      throw ErrorHandler.handleHttpError(response);
    }
  }
}

// data/repositories/champion_repository_impl.dart
class ChampionRepositoryImpl implements ChampionRepository {
  @override
  Future<void> updateChampion(ChampionEntity champion) async {
    final token = await getToken();
    if (token == null) throw Exception('No autorizado');
    
    await remoteDataSource.updateChampion(champion, token);
  }
}
```

### 3. Presentation Layer
```dart
// presentation/providers/champions_provider.dart
class ChampionProvider extends ChangeNotifier {
  final UpdateChampionUseCase _updateChampionUseCase;

  Future<bool> updateChampion(ChampionEntity champion) async {
    try {
      await _updateChampionUseCase(champion);
      // Actualizar en lista local
      final index = _champions.indexWhere((c) => c.id == champion.id);
      if (index != -1) {
        _champions[index] = champion;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
}
```

### 4. Service Locator
```dart
// core/di/service_locator.dart
// En setupServiceLocator():
_instance.registerSingleton<UpdateChampionUseCase>(
  UpdateChampionUseCase(repository: _instance<ChampionRepository>()),
);
```

### 5. UI
```dart
// screens/champion_edit_screen.dart (nuevo)
class ChampionEditScreen extends StatefulWidget {
  final ChampionEntity champion;
  
  const ChampionEditScreen({required this.champion});

  @override
  State<ChampionEditScreen> createState() => _ChampionEditScreenState();
}

class _ChampionEditScreenState extends State<ChampionEditScreen> {
  void _saveChanges(ChampionProvider provider) async {
    final updated = widget.champion.copyWith(
      name: _nameController.text,
      // ... más cambios
    );

    bool success = await provider.updateChampion(updated);
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Campeón')),
      body: Column(
        children: [
          TextField(controller: _nameController, decoration: ...),
          // ... más campos
          ElevatedButton(
            onPressed: () => _saveChanges(context.read<ChampionProvider>()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
```

**¡Sin tocar nada más! La arquitectura permite agregar features sin modificar código existente.**

---

## **7. Cambiar Implementación de Datos**

### De HTTP a HTTP + Caché

```dart
// Antes
_instance.registerSingleton<ChampionRepository>(
  ChampionRepositoryImpl(
    remoteDataSource: _instance<ChampionRemoteDataSource>(),
    getToken: () => _instance<AuthRepository>().getToken(),
  ),
);

// Después (sin cambiar nada en Domain o Presentation)
_instance.registerSingleton<ChampionRepository>(
  ChampionRepositoryCachedImpl(
    remoteDataSource: _instance<ChampionRemoteDataSource>(),
    cacheDataSource: _instance<ChampionLocalDataSource>(), // ← Nuevo
    getToken: () => _instance<AuthRepository>().getToken(),
  ),
);

// El resto del código sigue igual porque depende de ChampionRepository
```

---

## **Referencias Rápidas**

### Obtener Token del Repositorio
```dart
final token = await ServiceLocator.get<AuthRepository>().getToken();
```

### Acceder al Provider desde Screen
```dart
// Lectura
context.read<ChampionProvider>().champions;

// Escuchar cambios (reconstruir widget)
context.watch<ChampionProvider>().isLoading;

// Consumer para más control
Consumer<ChampionProvider>(builder: (context, provider, _) { })
```

### Lanzar Use Case Manualmente
```dart
final useCase = ServiceLocator.get<GetChampionsUseCase>();
final champions = await useCase(); // O await useCase.call()
```

### Manejo de Errores Común
```dart
try {
  await provider.loadChampions();
} on AppException catch (e) {
  print(e.message); // Legible para usuario
  print(e.code);   // Para logging
}
```

---

Estos ejemplos cubren los casos de uso más comunes. ¡La arquitectura es consistente en todos ellos!

