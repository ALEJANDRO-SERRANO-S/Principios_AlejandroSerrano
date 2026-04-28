# Chess App Mobile - Leyendas del Ajedrez 🏁

Una aplicación móvil Flutter que gestiona campeones de ajedrez con una arquitectura moderna, principios SOLID y patrones de diseño.

## 📱 Características

- ✅ **Autenticación JWT** con login y registro
- ✅ **CRUD de Campeones** (Crear, Leer, Actualizar, Eliminar)
- ✅ **Almacenamiento local** de tokens con SharedPreferences
- ✅ **Manejo de errores** robusto y personalizado
- ✅ **Arquitectura limpia** con separación de capas
- ✅ **Inyección de dependencias** con GetIt
- ✅ **Gestión de estado** con Provider (ChangeNotifier)
- ✅ **Principios SOLID** completamente implementados

## 🏗️ Arquitectura

El proyecto implementa **Clean Architecture** con las siguientes capas:

```
┌─────────────────────────────────────┐
│     PRESENTATION LAYER              │
│  (Screens, Providers, Widgets)      │
└──────────────────┬──────────────────┘
                   ↓
┌─────────────────────────────────────┐
│     DOMAIN LAYER                    │
│  (Entities, Repositories, UseCases) │
└──────────────────┬──────────────────┘
                   ↓
┌─────────────────────────────────────┐
│     DATA LAYER                      │
│  (Repositories impl, DataSources)   │
└──────────────────┬──────────────────┘
                   ↓
┌─────────────────────────────────────┐
│     CORE LAYER                      │
│  (Exceptions, Utils, Service Locator)
└─────────────────────────────────────┘
```

## 📚 Documentación

- [**ARCHITECTURE.md**](docs/ARCHITECTURE.md) - Estructura y diseño del proyecto
- [**SOLID_PRINCIPLES.md**](docs/SOLID_PRINCIPLES.md) - Cómo se implementan los principios SOLID
- [**DESIGN_PATTERNS.md**](docs/DESIGN_PATTERNS.md) - Patrones de diseño utilizados
- [**USAGE_EXAMPLES.md**](docs/USAGE_EXAMPLES.md) - Ejemplos prácticos de uso

## 🚀 Quick Start

### Requisitos
- Flutter 3.11.4+
- Dart 3.11.4+

### Instalación

```bash
# Clonar el repositorio
git clone <repository-url>
cd app_mobile

# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run
```

### Configuración

La aplicación utiliza:
- **Backend**: https://api-ajedrez.onrender.com/api
- **Almacenamiento local**: SharedPreferences
- **Inyección de dependencias**: GetIt
- **Estado global**: Provider

## 📦 Estructura de Carpetas

```
lib/
├── core/                          # Utilidades comunes
│   ├── di/service_locator.dart   # Inyección de dependencias
│   ├── exceptions/               # Excepciones personalizadas
│   └── utils/                    # Helpers HTTP, almacenamiento
│
├── data/                          # Acceso a datos
│   ├── datasources/              # Fuentes de datos (HTTP)
│   └── repositories/             # Implementaciones de repositorios
│
├── domain/                        # Lógica de negocio
│   ├── entities/                 # Modelos de dominio
│   ├── repositories/             # Interfaces de repositorio
│   └── usecases/                 # Casos de uso
│
├── presentation/                  # Interfaz de usuario
│   ├── providers/                # ChangeNotifier (estado)
│   └── screens/                  # Pantallas
│
├── models/                        # Modelos (compatibilidad)
├── services/                      # Servicios (deprecado)
└── main.dart                      # Punto de entrada
```

## 🔄 Flujo de Datos

```
User Action (Tap Button)
    ↓
Screen / Consumer Widget
    ↓
ChangeNotifier Provider (update state)
    ↓
Use Case (apply business logic)
    ↓
Repository (abstract interface)
    ↓
Repository Implementation
    ↓
Remote Data Source (HTTP request)
    ↓
REST API
    ↓
[Response back through same chain]
```

## 🎯 Principios SOLID Implementados

### ✅ S - Single Responsibility
Cada clase tiene UN responsabilidad:
- `HttpHelper`: Solo parsing de respuestas
- `DataSource`: Solo comunicación HTTP
- `Repository`: Solo coordinación
- `Provider`: Solo estado

### ✅ O - Open/Closed
Abierto para extensión, cerrado para modificación:
- Agregar caché sin modificar código existente
- Cambiar API sin afectar capas superiores

### ✅ L - Liskov Substitution
Implementaciones intercambiables:
- `AuthRepository` → `AuthRepositoryImpl` o `AuthRepositoryMock`
- `ChampionRepository` → `ChampionRepositoryImpl` o `ChampionRepositoryCachedImpl`

### ✅ I - Interface Segregation
Interfaces pequeñas y focalizadas:
- `AuthRepository` (solo auth)
- `ChampionRepository` (solo campeones)
- `LocalStorageRepository` (solo almacenamiento)

### ✅ D - Dependency Inversion
Depender de abstracciones, no implementaciones:
- Service Locator centraliza dependencias
- Inyección en constructores
- Providers usan interfaces, no clases concretas

## 🎨 Patrones de Diseño

1. **Repository Pattern** - Abstracción de datos
2. **Data Source Pattern** - Separación de fuentes
3. **Use Case Pattern** - Encapsular lógica
4. **Service Locator Pattern** - Inyección de dependencias
5. **Singleton Pattern** - Instancia única (GetIt)
6. **Observer Pattern** - ChangeNotifier
7. **Builder Pattern** - Consumer widgets
8. **Factory Pattern** - Creación de entidades

## 🔐 Autenticación

### Login
```dart
final success = await authProvider.login(username, password);
// Token guardado automáticamente en SharedPreferences
```

### Logout
```dart
await authProvider.logout();
// Usuario redirigido a LoginScreen
```

### Token Persistencia
```dart
// En main.dart:
if (authProvider.isAuthenticated) {
  return ChampionsListScreen();
} else {
  return LoginScreen();
}
```

## 🔄 CRUD Operaciones

### Obtener Campeones
```dart
await championProvider.loadChampions();
List<ChampionEntity> champions = championProvider.champions;
```

### Agregar Campeón
```dart
final champion = ChampionEntity(
  name: 'Magnus Carlsen',
  birthCountry: 'Noruega',
  // ... más campos
);
bool success = await championProvider.addChampion(champion);
```

### Eliminar Campeón
```dart
bool success = await championProvider.deleteChampion(championId);
```

## 📊 Gestión de Estado

### AuthProvider
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    if (authProvider.state == AuthState.authenticated) {
      return Text('Bienvenido ${authProvider.user?.username}');
    }
    return Text('Por favor inicia sesión');
  },
)
```

### ChampionProvider
```dart
Consumer<ChampionProvider>(
  builder: (context, championProvider, _) {
    return ListView.builder(
      itemCount: championProvider.count,
      itemBuilder: (context, index) {
        final champion = championProvider.champions[index];
        return ChampionTile(champion: champion);
      },
    );
  },
)
```

## ⚠️ Manejo de Errores

Jerarquía de excepciones:
- `AppException` (base)
  - `AuthException` - Errores de autenticación
  - `NetworkException` - Errores de conexión
  - `ServerException` - Errores del servidor
  - `ValidationException` - Errores de validación
  - `AppGeneralException` - Otros errores

```dart
try {
  await provider.loadChampions();
} catch (e) {
  if (e is AppException) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message))
    );
  }
}
```

## 🧪 Testing

### Unit Test de Use Case
```dart
test('GetChampionsUseCase debe retornar lista', () async {
  final useCase = GetChampionsUseCase(repository: mockRepository);
  final result = await useCase();
  expect(result, isA<List<ChampionEntity>>());
});
```

### Widget Test
```dart
testWidgets('ChampionsListScreen muestra campeones', (tester) async {
  await tester.pumpWidget(testApp);
  expect(find.text('Magnus Carlsen'), findsOneWidget);
});
```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter: ^3.11.4
  provider: ^6.1.0          # Gestión de estado
  get_it: ^7.6.0            # Service Locator
  http: ^1.6.0              # Cliente HTTP
  shared_preferences: ^2.5.5 # Almacenamiento local
```

## 🔮 Mejoras Futuras

- [ ] Agregar caché local (Hive/SQLite)
- [ ] Implementar Riverpod en lugar de Provider
- [ ] Agregar unit tests completos
- [ ] Implementar GraphQL en lugar de REST
- [ ] Agregar push notifications
- [ ] Implementar sync offline-first
- [ ] Agregar analytics
- [ ] Mejorar UI/UX

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para cambios mayores, abre un issue primero.

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

## 👨‍💻 Autor

Alejandro Serrano

## 📞 Contacto

Para preguntas o sugerencias, por favor abre un issue en el repositorio.

---

## 🎓 Recursos Educativos

Este proyecto implementa conceptos avanzados de arquitectura:

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Design Patterns](https://refactoring.guru/design-patterns)
- [Provider Documentation](https://pub.dev/packages/provider)
- [GetIt Documentation](https://pub.dev/packages/get_it)

**¡Perfecto para aprender Clean Architecture y SOLID en Flutter!**

