# 🏗️ Diagrama de Arquitectura - Chess App Mobile

## Arquitectura General

```
┌────────────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Screens     │  │  Providers   │  │  Widgets     │          │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤          │
│  │ LoginScreen  │  │ AuthProvider │  │  Consumer    │          │
│  │ Champions... │  │ Champion...  │  │  Builder     │          │
│  │ DetailScr... │  │              │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│           ↕                ↕                                     │
│    User Interaction   State Management                          │
└──────────────────────────────────────────────────────────────────┘
                            ↑
                            │ Depends on
                            ↓
┌────────────────────────────────────────────────────────────────┐
│                   DOMAIN LAYER                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Entities    │  │ Repositories │  │  Use Cases   │          │
│  ├──────────────┤  │  (Interfaces)│  ├──────────────┤          │
│  │Champion...   │  ├──────────────┤  │ LoginUseCase │          │
│  │UserEntity    │  │ AuthRepo...  │  │ GetChampions │          │
│  │              │  │ ChampionRepo │  │ AddChampion  │          │
│  └──────────────┘  └──────────────┘  │ DeleteChamp..│          │
│                                        └──────────────┘          │
│  Pure Business Logic (No Flutter, No HTTP)                      │
└────────────────────────────────────────────────────────────────┘
                            ↑
                            │ Implements
                            ↓
┌────────────────────────────────────────────────────────────────┐
│                   DATA LAYER                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Data Sources│  │ Repositories │  │  Mappers     │          │
│  │ (Interfaces) │  │   (Impl)     │  │              │          │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤          │
│  │ AuthRemote.. │  │ AuthRepo...  │  │ JSON → Entity│          │
│  │ Champion...  │  │ ChampionRepo │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│           ↕                                                      │
│    HTTP Requests                                                │
└────────────────────────────────────────────────────────────────┘
                            ↑
                            │ Uses
                            ↓
┌────────────────────────────────────────────────────────────────┐
│                   CORE LAYER                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Exceptions   │  │   Utilities  │  │ Service      │          │
│  │              │  │              │  │ Locator      │          │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤          │
│  │ AppException │  │ HttpHelper   │  │ GetIt        │          │
│  │ AuthException│  │ ErrorHandler │  │ DI Setup     │          │
│  │ NetException │  │ LocalStorage │  │              │          │
│  │ ...          │  │              │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
│  Common utilities used by all layers                            │
└────────────────────────────────────────────────────────────────┘
```

---

## Flujo de Datos Detallado

### Caso de Uso: Cargar Campeones

```
┌─────────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                               │
│                                                                   │
│ ChampionsListScreen                                              │
│    ├── initState() calls:                                        │
│    └─→ context.read<ChampionProvider>().loadChampions()         │
│                    ↓                                              │
│    ChampionProvider (ChangeNotifier)                             │
│    ├── _state = loading                                          │
│    ├── notifyListeners() [rebuilds Consumer]                     │
│    └─→ await _getChampionsUseCase()                              │
└─────────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER                                                     │
│                                                                   │
│ GetChampionsUseCase                                              │
│    └─→ await repository.getChampions()                           │
│         (using abstract ChampionRepository)                      │
└─────────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────────┐
│ DATA LAYER                                                       │
│                                                                   │
│ ChampionRepositoryImpl                                            │
│    └─→ await remoteDataSource.getChampions()                     │
│                    ↓                                              │
│         ChampionRemoteDataSourceImpl                              │
│         ├── final response = await httpClient.get()              │
│         ├── if (200) return _parseChampions(response)            │
│         └─→ HttpHelper.parseJsonListResponse()                   │
│                    ↓                                              │
└─────────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────────┐
│ CORE LAYER                                                       │
│                                                                   │
│ HttpHelper                                                       │
│ ├── Parses JSON to Map                                           │
│ ├── Handles errors                                               │
│ └─→ Returns List<Map>                                            │
│                    ↓                                              │
└─────────────────────────────────────────────────────────────────┘
                    ↓
        ┌──────────────────────────┐
        │  ChampionRemoteDataSource │
        │  (continues...)           │
        │  Maps each JSON to:       │
        │  ChampionEntity(...)      │
        │  Returns:                 │
        │  List<ChampionEntity>     │
        └──────────────────────────┘
                    ↓
        ┌──────────────────────────┐
        │  ChampionRepositoryImpl    │
        │  Returns:                 │
        │  List<ChampionEntity>     │
        └──────────────────────────┘
                    ↓
        ┌──────────────────────────┐
        │  GetChampionsUseCase      │
        │  Returns:                 │
        │  List<ChampionEntity>     │
        └──────────────────────────┘
                    ↓
        ┌──────────────────────────┐
        │  ChampionProvider         │
        │  _champions = entities    │
        │  _state = loaded          │
        │  notifyListeners()        │
        └──────────────────────────┘
                    ↓
        ┌──────────────────────────┐
        │  Consumer<ChampionProvider>
        │  Rebuilds with:           │
        │  - isLoading: false       │
        │  - champions: [...]       │
        │  - UI shows list          │
        └──────────────────────────┘
```

---

## Estructura de Inyección de Dependencias

```
ServiceLocator.setupServiceLocator()
│
├─── NIVEL 1: CORE UTILITIES
│    ├── registerSingleton<http.Client>()
│    │   └── Única instancia HTTP
│    │
│    └── registerSingleton<LocalStorageRepository>()
│        └── Única instancia almacenamiento
│
├─── NIVEL 2: DATA SOURCES
│    ├── registerSingleton<AuthRemoteDataSource>(
│    │   httpClient: http.Client
│    │ )
│    │
│    └── registerSingleton<ChampionRemoteDataSource>(
│        httpClient: http.Client
│      )
│
├─── NIVEL 3: REPOSITORIES
│    ├── registerSingleton<AuthRepository>(
│    │   AuthRepositoryImpl(
│    │     remoteDataSource: AuthRemoteDataSource,
│    │     localStorageRepository: LocalStorageRepository
│    │   )
│    │ )
│    │
│    └── registerSingleton<ChampionRepository>(
│        ChampionRepositoryImpl(
│          remoteDataSource: ChampionRemoteDataSource,
│          getToken: AuthRepository.getToken
│        )
│      )
│
├─── NIVEL 4: USE CASES
│    ├── registerSingleton<LoginUseCase>(
│    │   LoginUseCase(
│    │     repository: AuthRepository
│    │   )
│    │ )
│    ├── registerSingleton<GetChampionsUseCase>(
│    │   GetChampionsUseCase(
│    │     repository: ChampionRepository
│    │   )
│    │ )
│    └── ... (más use cases)
│
└─── NIVEL 5: PROVIDERS (opcional, también en main.dart)
     ├── AuthProvider(
     │   loginUseCase: ServiceLocator.get(),
     │   registerUseCase: ServiceLocator.get(),
     │   ...
     │ )
     │
     └── ChampionProvider(
         getChampionsUseCase: ServiceLocator.get(),
         addChampionUseCase: ServiceLocator.get(),
         ...
       )
```

---

## Patrones SOLID Visualizados

### Single Responsibility (SRP)

```
┌─────────────────────────────────────────────────────┐
│                   ANTES (Violación)                  │
│                                                      │
│   ChampionService                                    │
│   ├── HTTP Requests         ← Responsabilidad 1    │
│   ├── JSON Parsing          ← Responsabilidad 2    │
│   ├── Token Management      ← Responsabilidad 3    │
│   ├── Error Handling        ← Responsabilidad 4    │
│   └── Caching (futuro)      ← Responsabilidad 5    │
│                                                      │
│   1 clase = 5 responsabilidades ❌                 │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                   DESPUÉS (SOLID)                    │
│                                                      │
│   HttpHelper                                         │
│   └── JSON Parsing ✓                                │
│                                                      │
│   ChampionRemoteDataSource                          │
│   └── HTTP Requests ✓                               │
│                                                      │
│   ChampionRepository                                │
│   └── Token Management ✓                            │
│                                                      │
│   ErrorHandler                                      │
│   └── Error Handling ✓                              │
│                                                      │
│   N clases = 1 responsabilidad cada una ✅         │
└─────────────────────────────────────────────────────┘
```

### Dependency Inversion (DIP)

```
┌─────────────────────────────────────────────────────┐
│                   ANTES (Alto Nivel depende de Bajo) │
│                                                      │
│   ChampionDetailScreen                              │
│   └─→ depends on → ChampionService (concrete)       │
│                   └─→ depends on → http.get()       │
│                                                      │
│   ❌ High level depends on low level                │
│   ❌ Cannot test without HTTP                       │
│   ❌ Cannot change implementation                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                   DESPUÉS (DIP)                      │
│                                                      │
│   ChampionDetailScreen                              │
│   └─→ depends on → ChampionProvider                 │
│        └─→ depends on → ChampionRepository (interface)
│             └─→ can be any implementation           │
│                ├─→ ChampionRepositoryImpl           │
│                ├─→ ChampionRepositoryCached        │
│                └─→ ChampionRepositoryMock          │
│                                                      │
│   ✅ High level depends on abstraction             │
│   ✅ Easy to test with mocks                        │
│   ✅ Easy to change implementation                 │
└─────────────────────────────────────────────────────┘
```

---

## Ciclo de Vida de la Aplicación

```
1. main() async {
2.    await ServiceLocator.setupServiceLocator();
      └─→ Registra todas las dependencias
      └─→ Inicializa SharedPreferences
      └─→ Crea instancias singleton
3.    runApp(const ChessApp());
      └─→ Inicia aplicación
   }

4. ChessApp builds:
   ├─→ MultiProvider(providers: [
   │   ├─→ ChangeNotifierProvider(AuthProvider),
   │   └─→ ChangeNotifierProvider(ChampionProvider)
   │ ])
   └─→ MaterialApp(home: AuthWrapper)

5. AuthWrapper Consumer<AuthProvider>:
   ├─→ AuthProvider._checkAuthentication()
   │   └─→ IsAuthenticatedUseCase.call()
   │       └─→ AuthRepository.isAuthenticated()
   │           └─→ LocalStorageRepository.getString('jwt_token')
   │
   └─→ if (isAuth) {
         return ChampionsListScreen()
       } else {
         return LoginScreen()
       }

6. ChampionsListScreen initState:
   └─→ context.read<ChampionProvider>().loadChampions()
       └─→ GetChampionsUseCase.call()
           └─→ ChampionRepository.getChampions()
               └─→ ChampionRemoteDataSource.getChampions()
                   └─→ HTTP GET /api/champions
                       └─→ Parse JSON
                           └─→ Return List<ChampionEntity>

7. Pantalla renderiza:
   ├─→ Consumer<ChampionProvider>
   │   ├─→ if (isLoading) CircularProgressIndicator()
   │   ├─→ if (isEmpty) "Sin datos"
   │   └─→ ListView(champions)
   │
   └─→ User ve lista
```

---

## Interacción Usuario - Aplicación

```
┌─────────────────────────────────────────────────────┐
│  USER                                                │
│  ├─→ Tap Login Button                              │
│  ├─→ Enters credentials                             │
│  ├─→ Tap ENTRAR                                     │
│  └─→ RECIBE LISTA DE CAMPEONES                     │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                  │
│  LoginScreen._submit(authProvider)                  │
│    └─→ authProvider.login(username, password)      │
│        └─→ _state = loading                        │
│        └─→ notifyListeners()                       │
│        └─→ await LoginUseCase(...)                 │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  DOMAIN LAYER                                        │
│  LoginUseCase.call(username, password)             │
│    └─→ await repository.login(...)                 │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  DATA LAYER                                          │
│  AuthRepositoryImpl.login(username, password)       │
│    └─→ token = await remoteDataSource.login(...)   │
│    └─→ await localStorage.setString('jwt_token')   │
│    └─→ return UserEntity(token: token)             │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  HTTP (Remote)                                       │
│  POST https://api-ajedrez.onrender.com/api/auth    │
│  ├─→ Request: {username, password}                 │
│  └─→ Response: {accessToken: "jwt..."}             │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (resultado)                     │
│  authProvider._user = UserEntity(...)              │
│  authProvider._state = authenticated               │
│  authProvider.notifyListeners()                    │
│    └─→ AuthWrapper.Consumer reconstruye           │
│        └─→ Detecta isAuthenticated = true          │
│        └─→ Navega a ChampionsListScreen           │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  USER VE                                             │
│  ✅ Pantalla de Campeones                          │
│  ✅ Lista de maestros del ajedrez                  │
│  ✅ Puede hacer CRUD                               │
│  ✅ Puede Logout                                    │
└─────────────────────────────────────────────────────┘
```

---

## Comparación: Antes vs Después

```
ANTES                           DESPUÉS
┌────────────┐                 ┌─────────────────┐
│   Screen   │                 │     Screen      │
│  (tightly  │                 │  (loosely       │
│  coupled)  │                 │   coupled)      │
└─────┬──────┘                 └────────┬────────┘
      │                                  │
      ↓                                  ↓
┌──────────────────┐           ┌──────────────────┐
│  AuthService     │           │  AuthProvider    │
│  (does too much) │           │  (state only)    │
└─────┬──────────────┘          └────────┬────────┘
      │                                  │
      ├─ HTTP                          ├─ Uses
      ├─ Token storage                 │
      ├─ Error handling      ┌──────────┴────────┬──────────────┐
      └─ ...                 │                    │               │
                         LoginUseCase      RegisterUseCase    ...
❌ Hard to test              │                    │
❌ Hard to extend           └──────────────┬──────┴──────────┘
❌ Violates SOLID               │
❌ Tightly coupled              ↓
                          AuthRepository (interface)
                               │
                               ├─ AuthRepositoryImpl
                               ├─ AuthRepositoryMock
                               └─ AuthRepositoryCached
                          
                          ✅ Easy to test
                          ✅ Easy to extend
                          ✅ Follows SOLID
                          ✅ Loosely coupled
```

---

## Resumen Visual

```
    USER INPUT
        ↓
    SCREENS
    (Presentation)
        ↓
    PROVIDERS
    (State Management)
        ↓
    USE CASES
    (Business Logic)
        ↓
    REPOSITORIES (Interface)
    (Data Abstraction)
        ↓
    REPOSITORIES (Implementation)
    (Data Access)
        ↓
    DATA SOURCES
    (HTTP, Local, Cache)
        ↓
    EXTERNAL SERVICES
    (API, Database, Storage)
        ↓
    DATA FLOWS BACK UP
        ↓
    UI UPDATES
    (via notifyListeners)
```

**Cada flecha = inversión de dependencias → menos acoplamiento**

---

Diagrama generado automáticamente. Para versión visual interactiva, usar herramientas como:
- Figma
- Draw.io
- Miro
- Lucidchart

