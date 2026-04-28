# API de Ajedrez

API REST construida con Spring Boot para gestionar usuarios, autenticación JWT y campeones de ajedrez.

## Arquitectura

El proyecto se organiza en capas para respetar principios SOLID:

- `controllers/`: adaptan HTTP y delegan lógica.
- `services/`: contienen la lógica de negocio.
- `repository/`: acceso a datos con Spring Data JPA.
- `models/`: entidades del dominio.
- `payload/request` y `payload/response`: contratos de entrada y salida.
- `exception/`: manejo global de errores.
- `security/`: configuración de autenticación y autorización.

## Principales decisiones de diseño

- **SRP**: los controladores ya no acceden directamente a repositorios.
- **DIP**: los controladores dependen de servicios, no de detalles de persistencia.
- **OCP**: el mapeo y manejo de errores están encapsulados en clases específicas.
- **Encapsulación**: las entidades no se exponen directamente en todos los endpoints.

## Endpoints principales

### Auth
- `POST /api/auth/signin`
- `POST /api/auth/signup`

### Champions
- `GET /api/champions`
- `POST /api/champions`
- `PUT /api/champions/{id}`
- `DELETE /api/champions/{id}`

## Configuración

Variables de entorno esperadas:

```bash
DB_URL=jdbc:postgresql://localhost:5432/ajedrez
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=your-secret-key
JWT_EXPIRATION_MS=86400000
```

## Ejecución

```bash
./mvnw spring-boot:run
```

## Build

```bash
./mvnw clean test
./mvnw clean package
```

