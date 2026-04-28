Resumen de la refactorización y documentación del proyecto
=============================================================

Breve recibo y plan
-------------------

Estoy documentando el proyecto y los cambios realizados durante la refactorización orientada a principios SOLID y patrones de diseño. Este documento recoge: el porqué de los cambios, la lista de archivos modificados/creados, las decisiones de diseño, ejemplos de uso de la API, cómo ejecutar y probar el proyecto, problemas detectados y próximos pasos recomendados.

Checklist (hechos)
-------------------

- [x] Separación de responsabilidades: Controllers → Services → Repositories
- [x] Introducción de DTOs para entrada/salida (no exponer entidades JPA directamente)
- [x] Mapper simple para Champions (ChampionMapper)
- [x] Manejador global de excepciones (GlobalExceptionHandler)
- [x] Validaciones en entidades (`Champion`, `User`) con Bean Validation
- [x] Refactor de seguridad (JwtUtils, AuthTokenFilter, WebSecurityConfig) para inyección y consistencia
- [x] Normalización de propiedades de JWT (`app.jwt.secret`, `app.jwt.expiration-ms`) y alias legacy
- [x] README básico explicando arquitectura y cómo ejecutar
- [x] Generación de un jar (build realizado)

Visión general de la arquitectura
---------------------------------

El proyecto ahora sigue un patrón clásico en capas:

- controllers: reciben la petición HTTP, validan la entrada mínima y delegan al servicio.
- services: lógica de negocio, transacciones, orquestación y validaciones de dominio.
- repository: acceso a la base de datos con Spring Data JPA.
- payload.request / payload.response: DTOs que definen el contrato de la API.
- models: entidades JPA del dominio.
- exception: excepciones personalizadas y `@RestControllerAdvice` para respuestas uniformes.
- security: configuración de seguridad, JWT y filtros.

Decisiones de diseño & Principios SOLID aplicados
------------------------------------------------

- SRP (Single Responsibility): cada clase tiene una sola responsabilidad (ej. controllers solo adaptan HTTP, servicios contienen la lógica).
- OCP (Open/Closed): mappers y excepciones permiten añadir nuevos formatos de respuesta sin cambiar la lógica de negocio.
- LSP (Liskov): las abstracciones públicas se mantienen compatibles con las implementaciones.
- ISP (Interface Segregation): se expusieron DTOs pequeños en lugar de las entidades completas.
- DIP (Dependency Inversion): controllers dependen de servicios; servicios dependen de repositorios (inversión de dependencias mediante Spring DI).

Patrones utilizados
-------------------

- Service Layer: `ChampionService` y `AuthService`.
- DTO + Mapper: `ChampionRequest`, `ChampionResponseDTO`, `ChampionMapper`.
- ControllerAdvice: `GlobalExceptionHandler` para manejo de errores uniforme.
- Factory/Builder (ligero): `ApiApplication` asegura la inicialización idempotente de roles.

Lista de archivos creados y modificados
--------------------------------------

Nuevos archivos (añadidos):
- src/main/java/com/ajedrez/api/payload/request/ChampionRequest.java (record) — DTO de entrada.
- src/main/java/com/ajedrez/api/payload/response/ChampionResponseDTO.java — DTO de salida.
- src/main/java/com/ajedrez/api/payload/response/ApiErrorResponse.java — formato de error JSON.
- src/main/java/com/ajedrez/api/exception/ResourceNotFoundException.java
- src/main/java/com/ajedrez/api/exception/DuplicateResourceException.java
- src/main/java/com/ajedrez/api/exception/ForbiddenOperationException.java
- src/main/java/com/ajedrez/api/exception/GlobalExceptionHandler.java
- src/main/java/com/ajedrez/api/services/ChampionMapper.java
- src/main/java/com/ajedrez/api/services/ChampionService.java
- src/main/java/com/ajedrez/api/services/AuthService.java
- docs/REFACTOR_REPORT.md (este archivo)

Archivos modificados (principales):
- src/main/java/com/ajedrez/api/controllers/ChampionController.java — ahora delega en `ChampionService` y usa DTOs.
- src/main/java/com/ajedrez/api/controllers/AuthController.java — delega en `AuthService`.
- src/main/java/com/ajedrez/api/models/Champion.java — validaciones JPA y BeanValidation.
- src/main/java/com/ajedrez/api/models/User.java — marca password y roles con `@JsonIgnore` para evitar exposiciones accidentales.
- src/main/java/com/ajedrez/api/security/jwt/JwtUtils.java — lectura de propiedades normalizada y firma con UTF-8 explícito.
- src/main/java/com/ajedrez/api/security/jwt/AuthTokenFilter.java — inyección por constructor.
- src/main/java/com/ajedrez/api/security/WebSecurityConfig.java — inyección por constructor y registro explícito del filtro JWT.
- src/main/java/com/ajedrez/api/ApiApplication.java — helper `ensureRole` para inicializar roles de forma idempotente.
- src/main/resources/application.properties — renombradas propiedades JWT y alias legacy añadidos.
- README.md — descripción de arquitectura y cómo ejecutar.

Detalles y explicaciones por cambio
----------------------------------

1) Separación de Controller → Service
- Por qué: evitar lógica de negocio en controllers facilita tests unitarios y respeta SRP.
- Cambios: `ChampionController` y `AuthController` ahora son thin controllers que delegan en `ChampionService` y `AuthService`.

2) DTOs y Mapper
- Por qué: evita que versiones de entidades JPA expongan internals (p. ej. proxies de Hibernate, contraseñas). Facilita versionado y evolución del API.
- Cambios: `ChampionRequest` (entrada), `ChampionResponseDTO` (salida), `ChampionMapper` (traductor).
- Nota: si quieres, podemos usar MapStruct para mappers generados automáticamente.

3) Manejo de excepciones centralizado
- Por qué: respuestas consistentes, mejor logging y separación de las respuestas HTTP de la lógica de negocio.
- Cambios: `GlobalExceptionHandler` captura excepciones personalizadas y comunes (validación, acceso denegado, auth errors).

4) Seguridad y JWT
- Por qué: robustez y consistencia; evitar usar cadenas "mágicas" ni props con nombres dispersos.
- Cambios: `JwtUtils` pasó a leer `app.jwt.secret` y `app.jwt.expiration-ms` (manteniendo alias `bezkoder.*` por compatibilidad).
- `AuthTokenFilter` ahora se construye con sus dependencias (fácil de mockear en tests de integración).

5) Entidades
- `Champion`: validaciones (`@NotBlank`, `@Size`, `@Min`) y `@Column` más restrictivos que previenen errores por URLs largas.
- `User`: `@JsonIgnore` en `password` y `roles` para reducir riesgo de fuga de datos en respuestas JSON.

API — Endpoints y formatos (ejemplos)
-------------------------------------

Rutas principales (sin cambios en paths):
- POST /api/auth/signin  — autentica y devuelve `JwtResponse`
- POST /api/auth/signup  — registra nuevo usuario y devuelve `MessageResponse`
- GET  /api/champions     — lista campeones (ahora devuelve `ChampionResponseDTO`)
- POST /api/champions     — crea campeón (acepta `ChampionRequest`)
- PUT  /api/champions/{id}— actualiza campeón (acepta `ChampionRequest`)
- DELETE /api/champions/{id} — borra campeón (propietario o admin)

ChampionRequest (ejemplo JSON de entrada):

{
  "name": "Magnus Carlsen",
  "birthCountry": "Noruega",
  "representedCountry": "Noruega",
  "ageAtFirstWin": 13,
  "period": "2004-2013",
  "imageUrl": "https://.../magnus.jpg",
  "bio": "Gran campeón..."
}

ChampionResponseDTO (ejemplo JSON de salida):

{
  "id": 1,
  "name": "Magnus Carlsen",
  "birthCountry": "Noruega",
  "representedCountry": "Noruega",
  "ageAtFirstWin": 13,
  "period": "2004-2013",
  "imageUrl": "https://.../magnus.jpg",
  "bio": "Gran campeón...",
  "postedBy": { "id": 2, "username": "juan", "email": "juan@example.com" }
}

JwtResponse (simplificado):
{
  "accessToken": "<token>",
  "tokenType": "Bearer",
  "id": 2,
  "username": "juan",
  "email": "juan@example.com",
  "roles": ["ROLE_USER"]
}

MessageResponse (simplificado):
{ "message": "User registered successfully." }

Ejemplos curl
-------------

Registro:

curl -X POST http://localhost:8080/api/auth/signup \
  -H 'Content-Type: application/json' \
  -d '{"username":"juan","email":"juan@example.com","password":"password123"}'

Login:

curl -X POST http://localhost:8080/api/auth/signin \
  -H 'Content-Type: application/json' \
  -d '{"username":"juan","password":"password123"}'

Crear campeón (ejemplo):

curl -X POST http://localhost:8080/api/champions \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <JWT_TOKEN>' \
  -d '{"name":"Magnus Carlsen","birthCountry":"Noruega","representedCountry":"Noruega","ageAtFirstWin":13,"period":"2004-2013","imageUrl":"https://...","bio":"..."}'

Configuración y variables de entorno
------------------------------------

Propiedades principales (en `application.properties`):

- `app.jwt.secret` — clave secreta JWT (env var alternativa: `JWT_SECRET`).
- `app.jwt.expiration-ms` — validez del token en ms (env var alternativa: `JWT_EXPIRATION_MS`).
- `spring.datasource.url` — URL JDBC de la base de datos (ej.: jdbc:postgresql://...)
- `spring.datasource.username`
- `spring.datasource.password`

Nota importante para tests: las pruebas unitarias/integ intentan levantar el contexto Spring y requieren una URL JDBC válida. Por defecto en tu entorno local debes exportar `DB_URL` con un valor que comience por `jdbc:` o configurar un profile de test que use H2.

Cómo ejecutar y pruebas
----------------------

Construir (sin tests, rápido):

```bash
./mvnw -DskipTests package
```

Construir y ejecutar tests (recomendado con profile test que use H2 en memoria):

1) Opción A — usar H2 para pruebas (se añadirá si lo deseas):
   - Crear `src/test/resources/application-test.properties` con:
     spring.datasource.url=jdbc:h2:mem:testdb
     spring.datasource.driverClassName=org.h2.Driver
     spring.jpa.hibernate.ddl-auto=create-drop
   - Ejecutar:

```bash
./mvnw -Dspring.profiles.active=test test
```

2) Opción B — exportar variables de entorno con credenciales de DB:

```bash
export DB_URL='jdbc:postgresql://localhost:5432/ajedrez'
export DB_USER=postgres
export DB_PASSWORD=postgres
./mvnw test
```

Ejecutar la aplicación:

```bash
export DB_URL='jdbc:postgresql://localhost:5432/ajedrez'
export DB_USER=postgres
export DB_PASSWORD=postgres
export JWT_SECRET='un-secreto-largo'
./mvnw spring-boot:run
# o
java -jar target/api-0.0.1-SNAPSHOT.jar
```

Problemas detectados durante la verificación
-------------------------------------------

- Al ejecutar `./mvnw test` sin definir `spring.datasource.url` (o si `DB_URL` no comienza con `jdbc:`) la inicialización del contexto falla con: "URL must start with 'jdbc'". Esto ocurre porque Spring intenta crear un DataSource real para las pruebas.
- Recomendación: añadir profile `test` con H2 (recomendado) o configurar `ApiApplicationTests` para sustituir la BD en tests.

Cambios que podrían afectar a clientes existentes (compatibilidad)
-----------------------------------------------------------------

- BREAKING: `GET /api/champions` ahora devuelve `ChampionResponseDTO` en lugar de la entidad JPA `Champion`. El JSON resultante es similar pero puede no ser idéntico (por ejemplo, falta de proxies de Hibernate, y campos serializados). Opciones:
  - mantener un endpoint legacy (`/api/v1/champions`) que devuelva la estructura anterior;
  - documentar el cambio y elevar versión de la API; o
  - adaptar los DTOs para que coincidan exactamente con la representación antigua.

Siguientes pasos recomendados (priorizados)
-------------------------------------------

1) Añadir pruebas unitarias para `ChampionService` y `AuthService` (usar Mockito para mockear repositorios y JwtUtils). — Prioridad ALTA.
2) Añadir pruebas de integración con H2 y profile `test`. — Prioridad ALTA.
3) Generar documentación OpenAPI (springdoc-openapi) y exponer Swagger UI. — Prioridad ALTA.
4) Añadir paginación en `ChampionService` y endpoints GET. — Prioridad MEDIA.
5) Considerar MapStruct para mapeos DTO (p. ej. `ChampionMapper`). — Prioridad MEDIA.
6) Añadir auditoría de entidades (createdAt, updatedAt, createdBy). — Prioridad MEDIA.

Notas finales
-------------

He dejado la API estable en cuanto a rutas y responsabilidades, pero en algunos lugares cambié la forma de las respuestas (DTOs). Si quieres que vuelva a hacer la salida idéntica a la original por compatibilidad, puedo añadir una capa de serialización/compatibilidad.

¿Quieres que implemente ahora alguna de las tareas priorizadas? Puedo empezar por:
- A: Añadir profile `test` con H2 y adaptar `ApiApplicationTests` para que pasen los tests en CI local.
- B: Añadir OpenAPI/Swagger y exponer la documentación automáticamente.
- C: Crear pruebas unitarias básicas para `ChampionService` y `AuthService`.

Indica la opción (A, B, C) que prefieras y la implementaré a continuación.

