# Arquitectura del Proyecto - Chess App Mobile

## Descripción General

Este proyecto implementa una arquitectura moderna basada en **Clean Architecture** (Arquitectura Limpia) combinada con **SOLID Principles** y **Design Patterns** reconocidos. La aplicación sigue un enfoque de separación en capas para maximizar la mantenibilidad, escalabilidad y testabilidad.

## Estructura de Carpetas

```
lib/
├── core/                          # Capa de núcleo (utilidades comunes)
│   ├── di/
│   │   └── service_locator.dart  # Inyección de dependencias (GetIt)
│   ├── exceptions/
│   │   └── app_exceptions.dart   # Excepciones personalizadas
│   └── utils/
│       ├── http_helper.dart      # Manejo de respuestas HTTP
│       └── local_storage_repository.dart # Almacenamiento local
│
├── data/                          # Capa de datos
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart      # Fuente remota de auth
│   │   └── champion_remote_datasource.dart  # Fuente remota de campeones
│   └── repositories/
│       ├── auth_repository_impl.dart        # Implementación del repo de auth
│       └── champion_repository_impl.dart    # Implementación del repo de campeones
│
├── domain/                        # Capa de dominio (lógica de negocio)
│   ├── entities/
│   │   └── entities.dart         # Entidades del dominio (ChampionEntity, UserEntity)
│   ├── repositories/
│   │   ├── auth_repository.dart        # Interfaz de repositorio de auth
│   │   └── champion_repository.dart    # Interfaz de repositorio de campeones
│   └── usecases/
│       ├── auth_usecases.dart         # Use cases de autenticación
│       └── champion_usecases.dart     # Use cases de campeones
│
├── presentation/                  # Capa de presentación
│   └── providers/
│       ├── auth_provider.dart         # ChangeNotifier para estado de auth
│       └── champions_provider.dart    # ChangeNotifier para estado de campeones
│
├── screens/                       # Pantallas de la aplicación
│   ├── login_screen.dart
│   ├── champion_detail_screen.dart
│   ├── champion_form_screen.dart
│   └── image_view_screen.dart
│
├── models/                        # Modelos (compatibilidad con código antiguo)
│   └── champion.dart
│
├── services/                      # Servicios (código antiguo - deprecado)
│   ├── auth_service.dart
│   └── champion_service.dart
│
└── main.dart                      # Punto de entrada
```

## Capas de Arquitectura

### 1. **Capa de Presentación (Presentation Layer)**
- **Responsabilidad**: Mostrar datos al usuario e interactuar con él
- **Componentes**:
  - `Screens`: Pantallas principales de la aplicación
  - `Providers`: Estado global usando `ChangeNotifier` (patrón Observer)
- **Patrones Aplicados**:
  - Provider Pattern (ChangeNotifier)
  - Builder Pattern (Consumer)
- **Cumple con SOLID**:
  - SRP: Cada provider gestiona un aspecto del estado
  - OCP: Fácil extender providers sin modificar existentes

### 2. **Capa de Dominio (Domain Layer)**
- **Responsabilidad**: Contener la lógica de negocio pura
- **Componentes**:
  - `Entities`: Objetos que representan conceptos de negocio (ChampionEntity, UserEntity)
  - `Repositories (Abstractions)`: Contratos que definen operaciones de datos
  - `Use Cases`: Encapsulan lógica de negocio específica
- **Patrones Aplicados**:
  - Repository Pattern
  - Use Case Pattern
- **Cumple con SOLID**:
  - DIP: Depende de abstracciones (interfaces), no de implementaciones
  - ISP: Interfaces segregadas (AuthRepository vs ChampionRepository)
  - SRP: Cada UseCase tiene una única responsabilidad

### 3. **Capa de Datos (Data Layer)**
- **Responsabilidad**: Implementar los repositorios y acceder a fuentes de datos
- **Componentes**:
  - `Remote Data Sources`: Comunican con APIs remotas (HTTP)
  - `Repository Implementations`: Implementan los contratos de Domain
  - `Models`: Mappers y conversores de datos
- **Patrones Aplicados**:
  - Data Source Pattern
  - Repository Pattern Implementation
- **Cumple con SOLID**:
  - SRP: DataSources solo manejan HTTP, Repositories coordinan
  - OCP: Fácil agregar nuevas datasources (ej: caché local)

### 4. **Capa de Núcleo (Core Layer)**
- **Responsabilidad**: Proporcionar utilidades comunes
- **Componentes**:
  - `Exceptions`: Jerarquía de excepciones personalizadas
  - `Service Locator`: Inyección de dependencias (GetIt)
  - `Utilities`: Helpers para HTTP, almacenamiento local
- **Patrones Aplicados**:
  - Service Locator Pattern
  - Singleton Pattern

## Flujo de Datos

```
User Interaction (Screen)
    ↓
Provider (ChangeNotifier)
    ↓
Use Case
    ↓
Repository (Abstract)
    ↓
Repository Implementation
    ↓
Remote Data Source
    ↓
HTTP / API
    ↓
[Response]
    ↓
Repository Implementation (mapea a Entity)
    ↓
Use Case (retorna Entity)
    ↓
Provider (actualiza estado)
    ↓
Screen (Consumer reconstruye UI)
```

## Inyección de Dependencias

Se utiliza **GetIt** (Service Locator) para centralizar la creación de instancias:

### Configuración en `service_locator.dart`:
```dart
// Nivel 1: Utilidades
registerSingleton<LocalStorageRepository>(...)
registerSingleton<http.Client>(...)

// Nivel 2: Data Sources
registerSingleton<AuthRemoteDataSource>(...)
registerSingleton<ChampionRemoteDataSource>(...)

// Nivel 3: Repositories
registerSingleton<AuthRepository>(...)
registerSingleton<ChampionRepository>(...)

// Nivel 4: Use Cases
registerSingleton<LoginUseCase>(...)
registerSingleton<GetChampionsUseCase>(...)
// ... etc
```

### Acceso desde cualquier parte del código:
```dart
// En un Provider
final loginUseCase = ServiceLocator.get<LoginUseCase>();

// O automático via inyección en constructor
AuthProvider({
  LoginUseCase? loginUseCase,
}) : _loginUseCase = loginUseCase ?? ServiceLocator.get()
```

## Gestión de Estado Global

Se utiliza **Provider** (ChangeNotifier) para estado global:

### AuthProvider
- Gestiona autenticación y usuario actual
- Estados: initial, loading, authenticated, unauthenticated, error
- Métodos: login(), register(), logout()

### ChampionProvider
- Gestiona lista de campeones
- Estados: initial, loading, loaded, error
- Métodos: loadChampions(), addChampion(), deleteChampion()

### Consumer en Screens
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isAuthenticated) {
      // Mostrar contenido autenticado
    }
  },
)
```

## Manejo de Errores

Jerarquía de excepciones en `app_exceptions.dart`:

```
AppException (base)
├── AuthException
├── NetworkException
├── ServerException
├── ValidationException
└── AppGeneralException
```

Cada excepción tiene:
- `message`: Descripción legible para usuario
- `code`: Identificador para programadores
- Métodos de utilidad en Providers para extraer información

## Patrones de Diseño Implementados

| Patrón | Ubicación | Propósito |
|--------|-----------|----------|
| **Repository** | Domain/Data | Abstrae el acceso a datos |
| **Use Case** | Domain | Encapsula lógica de negocio |
| **Service Locator** | Core/DI | Inyección de dependencias |
| **Singleton** | GetIt | Una única instancia de servicios |
| **Data Source** | Data | Abstrae fuentes de datos |
| **Provider/Observer** | Presentation | Notificación de cambios de estado |
| **Builder** | Presentation | Construcción condicional de widgets |
| **Factory** | Entities | Crear objetos desde JSON |

## Ventajas de esta Arquitectura

✅ **Mantenibilidad**: Código organizado en capas lógicas  
✅ **Testabilidad**: Fácil hacer unit tests (DIP, mocking)  
✅ **Escalabilidad**: Agregar nuevas features es predecible  
✅ **Reusabilidad**: Componentes desacoplados  
✅ **Flexibilidad**: Cambiar implementaciones sin afectar capas superiores  
✅ **Independencia de Frameworks**: Domain no depende de Flutter  

## Ejemplo: Agregar una Nueva Feature

Para agregar una nueva funcionalidad (ej: editar campeón):

1. **Domain Layer**:
   - Agregar `UpdateChampionUseCase` en `domain/usecases/champion_usecases.dart`
   - Agregar método `updateChampion()` a `ChampionRepository`

2. **Data Layer**:
   - Implementar método en `ChampionRemoteDataSourceImpl`
   - Implementar método en `ChampionRepositoryImpl`

3. **Presentation Layer**:
   - Agregar método `updateChampion()` a `ChampionProvider`

4. **Core/DI**:
   - Registrar `UpdateChampionUseCase` en `service_locator.dart`

5. **UI**:
   - Crear `champion_edit_screen.dart`
   - Usar provider para actualizar

¡Todo sin tocar las capas que no cambian!

## Dependencias Clave

```yaml
dependencies:
  flutter: ^3.x
  provider: ^6.1.0          # Estado global
  get_it: ^7.6.0            # Inyección de dependencias
  http: ^1.6.0              # Cliente HTTP
  shared_preferences: ^2.5.5 # Almacenamiento local
```

## Referencias

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Provider Package Documentation](https://pub.dev/packages/provider)
- [Repository Pattern](https://deviq.com/design-patterns/repository-pattern)
- [SOLID Principles (ver SOLID_PRINCIPLES.md)](./SOLID_PRINCIPLES.md)

