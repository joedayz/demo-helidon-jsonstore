# Demo Helidon con Oracle Database 23c y JSON Store

Este proyecto demuestra cómo usar Oracle Database 23c con capacidades nativas de JSON Store junto con Helidon MicroProfile para crear una API REST de gestión de gastos.

## Características

- **Entidad Expense**: Modelo de datos para gastos con anotaciones JPA
- **Oracle JSON Store**: Aprovecha las capacidades nativas de JSON de Oracle Database 23c
- **OracleJsonService**: Servicio optimizado para consultas JSON y estadísticas
- **REST API**: Endpoints avanzados para gestión y análisis de gastos
- **Oracle Database 23c Free**: Base de datos empresarial con soporte nativo para JSON
- **Tests**: Pruebas unitarias para verificar la funcionalidad

## Estructura del Proyecto

```
src/main/java/pe/joedayz/helidonjsonstore/
├── Expense.java              # Entidad JPA para Oracle JSON Store
├── OracleJsonService.java    # Servicio optimizado para Oracle JSON
└── ExpenseResource.java      # REST endpoints avanzados

src/main/resources/META-INF/
├── persistence.xml           # Configuración JPA para Oracle
├── microprofile-config.properties  # Configuración de Oracle Database
└── hibernate.properties      # Configuración de Hibernate para Oracle
```

## Configuración

### 1. Dependencias Maven

El proyecto incluye todas las dependencias necesarias:
- Helidon MicroProfile Core
- Hibernate (JPA implementation)
- Oracle Database JDBC Driver
- Oracle JSON Support
- CDI y JTA

### 2. Oracle Database 23c Free

#### Opción A: Docker Compose (Recomendado para equipos)

**Inicio Rápido (Recomendado):**

**Linux/macOS:**
```bash
chmod +x start-demo.sh
./start-demo.sh
```

**Windows:**
```powershell
.\start-demo.ps1
```

**Inicio Manual:**
```bash
# Iniciar solo la base de datos
docker-compose up -d oracle-db

# Ver logs
docker-compose logs -f oracle-db

# Verificar estado
docker-compose ps

# Acceder al contenedor
docker-compose exec oracle-db bash
```

**Para debugging (opcional):**
```bash
docker-compose --profile debug up sqlplus-client
```

**Configuración automática:**
- **Host**: `localhost`
- **Puerto**: `1521`
- **SID**: `FREE`
- **Usuario**: `C##helidon_user` (creado automáticamente)
- **Contraseña**: `helidon123`
- **Enterprise Manager**: `http://localhost:8080/em`
- **Aplicación Helidon**: `http://localhost:8081`

**Credenciales del sistema:**
- Usuario: `SYS` o `SYSTEM`
- Clave: `Oradoc_db1`

**Ventajas de esta configuración:**
- ✅ Usuario dedicado para la aplicación
- ✅ Privilegios mínimos necesarios
- ✅ Tablespace dedicado
- ✅ Configuración automática al iniciar
- ✅ Sin conflictos con usuarios del sistema

#### Opción B: Instalación Local

Si prefieres instalar Oracle Database 23c localmente, descárgalo desde [Oracle Database Free](https://www.oracle.com/database/free/).

### 3. JPA Configuration

- **Persistence Unit**: `pu1`
- **Transaction Type**: JTA
- **Auto DDL**: `update` (crea/actualiza tablas automáticamente)
- **Dialect**: Oracle 23c

## API Endpoints

### Operaciones CRUD Básicas

#### GET /expenses
Obtiene todos los gastos ordenados por fecha de creación

#### GET /expenses/{id}
Obtiene un gasto específico por ID

#### POST /expenses
Crea un nuevo gasto

#### PUT /expenses/{id}
Actualiza un gasto existente

#### DELETE /expenses/{id}
Elimina un gasto

### Consultas Avanzadas

#### GET /expenses/category/{category}
Obtiene gastos por categoría (FOOD, TRANSPORT, SHOPPING, etc.)

#### GET /expenses/method/{method}
Obtiene gastos por método de pago (CARD, CASH, DEBIT, CREDIT)

#### GET /expenses/amount-range?min={min}&max={max}
Obtiene gastos dentro de un rango de montos

#### GET /expenses/search?q={description}
Busca gastos por descripción (búsqueda de texto)

### Análisis y Estadísticas

#### GET /expenses/statistics
Obtiene estadísticas generales (total, promedio, conteo)

#### GET /expenses/total/category/{category}
Obtiene el total gastado en una categoría específica

#### GET /expenses/total/method/{method}
Obtiene el total gastado con un método de pago específico

## Ejemplos de Uso

### Operaciones CRUD Básicas

#### Crear un Gasto

**Linux/macOS (curl):**
```bash
curl -X POST http://localhost:8081/expenses \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 25.50,
    "method": "CARD",
    "category": "FOOD",
    "description": "Lunch at restaurant"
  }'
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses" -Method POST -ContentType "application/json" -Body '{
  "amount": 25.50,
  "method": "CARD",
  "category": "FOOD",
  "description": "Lunch at restaurant"
}'
```

#### Obtener Todos los Gastos

**Linux/macOS (curl):**
```bash
curl http://localhost:8081/expenses
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses" -Method GET
```

#### Obtener un Gasto por ID

**Linux/macOS (curl):**
```bash
curl http://localhost:8081/expenses/{id}
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/{id}" -Method GET
```

#### Actualizar un Gasto

**Linux/macOS (curl):**
```bash
curl -X PUT http://localhost:8081/expenses/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 30.00,
    "method": "CARD",
    "category": "FOOD",
    "description": "Dinner at restaurant"
  }'
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/{id}" -Method PUT -ContentType "application/json" -Body '{
  "amount": 30.00,
  "method": "CARD",
  "category": "FOOD",
  "description": "Dinner at restaurant"
}'
```

#### Eliminar un Gasto

**Linux/macOS (curl):**
```bash
curl -X DELETE http://localhost:8081/expenses/{id}
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/{id}" -Method DELETE
```

### Consultas Avanzadas

#### Obtener Gastos por Categoría

**Linux/macOS (curl):**
```bash
curl http://localhost:8081/expenses/category/FOOD
curl http://localhost:8081/expenses/category/TRANSPORT
curl http://localhost:8081/expenses/category/SHOPPING
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/category/FOOD" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/category/TRANSPORT" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/category/SHOPPING" -Method GET
```

#### Obtener Gastos por Método de Pago

**Linux/macOS (curl):**
```bash
curl http://localhost:8081/expenses/method/CARD
curl http://localhost:8081/expenses/method/CASH
curl http://localhost:8081/expenses/method/DEBIT
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/method/CARD" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/method/CASH" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/method/DEBIT" -Method GET
```

#### Buscar Gastos por Rango de Monto

**Linux/macOS (curl):**
```bash
curl "http://localhost:8081/expenses/amount-range?min=10&max=50"
curl "http://localhost:8081/expenses/amount-range?min=100&max=500"
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/amount-range?min=10&max=50" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/amount-range?min=100&max=500" -Method GET
```

#### Buscar Gastos por Descripción

**Linux/macOS (curl):**
```bash
curl "http://localhost:8080/expenses/search?q=restaurant"
curl "http://localhost:8080/expenses/search?q=gas"
curl "http://localhost:8080/expenses/search?q=shopping"
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/search?q=restaurant" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/search?q=gas" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/search?q=shopping" -Method GET
```

### Análisis y Estadísticas

#### Obtener Estadísticas Generales

**Linux/macOS (curl):**
```bash
curl http://localhost:8081/expenses/statistics
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/statistics" -Method GET
```

#### Obtener Total por Categoría

**Linux/macOS (curl):**
```bash
curl http://localhost:8081/expenses/total/category/FOOD
curl http://localhost:8081/expenses/total/category/TRANSPORT
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/total/category/FOOD" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/total/category/TRANSPORT" -Method GET
```

#### Obtener Total por Método de Pago

**Linux/macOS (curl):**
```bash
curl http://localhost:8081/expenses/total/method/CARD
curl http://localhost:8081/expenses/total/method/CASH
```

**Windows (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/expenses/total/method/CARD" -Method GET
Invoke-RestMethod -Uri "http://localhost:8081/expenses/total/method/CASH" -Method GET
```

### Ejemplos de Datos de Prueba

#### Crear Múltiples Gastos para Pruebas

**Linux/macOS (curl):**
```bash
# Gasto de comida
curl -X POST http://localhost:8081/expenses \
  -H "Content-Type: application/json" \
  -d '{"amount": 45.80, "method": "CARD", "category": "FOOD", "description": "Groceries at supermarket"}'

# Gasto de transporte
curl -X POST http://localhost:8081/expenses \
  -H "Content-Type: application/json" \
  -d '{"amount": 15.50, "method": "CASH", "category": "TRANSPORT", "description": "Taxi ride"}'

# Gasto de compras
curl -X POST http://localhost:8081/expenses \
  -H "Content-Type: application/json" \
  -d '{"amount": 89.99, "method": "DEBIT", "category": "SHOPPING", "description": "New shoes"}'

# Gasto de entretenimiento
curl -X POST http://localhost:8081/expenses \
  -H "Content-Type: application/json" \
  -d '{"amount": 25.00, "method": "CARD", "category": "ENTERTAINMENT", "description": "Movie tickets"}'
```

**Windows (PowerShell):**
```powershell
# Gasto de comida
Invoke-RestMethod -Uri "http://localhost:8081/expenses" -Method POST -ContentType "application/json" -Body '{"amount": 45.80, "method": "CARD", "category": "FOOD", "description": "Groceries at supermarket"}'

# Gasto de transporte
Invoke-RestMethod -Uri "http://localhost:8081/expenses" -Method POST -ContentType "application/json" -Body '{"amount": 15.50, "method": "CASH", "category": "TRANSPORT", "description": "Taxi ride"}'

# Gasto de compras
Invoke-RestMethod -Uri "http://localhost:8081/expenses" -Method POST -ContentType "application/json" -Body '{"amount": 89.99, "method": "DEBIT", "category": "SHOPPING", "description": "New shoes"}'

# Gasto de entretenimiento
Invoke-RestMethod -Uri "http://localhost:8081/expenses" -Method POST -ContentType "application/json" -Body '{"amount": 25.00, "method": "CARD", "category": "ENTERTAINMENT", "description": "Movie tickets"}'
```

## Ejecutar el Proyecto

### 1. Compilar

```bash
mvn clean compile
```

### 2. Ejecutar

```bash
mvn exec:java
```

### 3. Ejecutar Tests

```bash
mvn test
```

## 🧪 Scripts de Pruebas Automatizadas

Para facilitar las pruebas, hemos creado scripts que prueban todos los endpoints automáticamente:

### **Windows (PowerShell):**
```powershell
.\test-examples.ps1
```

### **Linux/macOS (Bash):**
```bash
./test-examples.sh
```

Estos scripts:
- ✅ Crean gastos de prueba automáticamente
- ✅ Prueban todos los endpoints CRUD
- ✅ Prueban consultas avanzadas y estadísticas
- ✅ Muestran resultados formateados
- ✅ Manejan errores graciosamente

**Requisitos:**
- **Windows**: PowerShell 5.1+ (incluido por defecto)
- **Linux/macOS**: `curl` y `jq` (opcional para mejor formato)

## Notas Importantes

1. **Oracle Database 23c**: Este proyecto está optimizado para usar Oracle Database 23c con capacidades nativas de JSON Store.

2. **JPA Estándar**: Se usa JPA estándar con Hibernate para mayor compatibilidad y estabilidad.

3. **Transacciones**: Todas las operaciones del servicio están marcadas con `@Transactional`.

4. **Auto DDL**: Hibernate creará automáticamente las tablas necesarias al iniciar la aplicación.

5. **Docker**: Se recomienda usar Oracle Database 23c Free en Docker para desarrollo.

6. **JSON Store**: Oracle Database 23c proporciona soporte nativo para JSON con excelente rendimiento.

## Personalización

### Cambiar Base de Datos

Para usar otra base de datos (MySQL, PostgreSQL, etc.):

1. Agregar la dependencia del driver en `pom.xml`
2. Actualizar `microprofile-config.properties`
3. Cambiar el dialecto en `hibernate.properties`

### Agregar Nuevas Entidades

1. Crear la clase con anotaciones JPA
2. Agregar la clase al `persistence.xml`
3. Crear el repository correspondiente
4. Crear los endpoints REST

## Troubleshooting

### Error de Conexión a Oracle Database
- Verificar que Oracle Database 23c esté ejecutándose (Docker o local)
- Verificar que el puerto 1521 esté accesible
- Revisar credenciales en `microprofile-config.properties`
- Verificar que el SID sea `FREE` para Oracle Database Free

### Error de Persistence Unit
- Verificar que la entidad `Expense` esté declarada en `persistence.xml`
- Revisar que las anotaciones JPA sean correctas
- Verificar que el dialecto sea `OracleDialect`

### Error de Transacciones
- Verificar que `@Transactional` esté presente en `OracleJsonService`
- Revisar la configuración JTA en `persistence.xml`

### Problemas Comunes con Docker
```bash
# Si el contenedor no inicia correctamente
docker logs oracle-23ai

# Si necesitas reiniciar
docker stop oracle-23ai
docker rm oracle-23ai
docker run -d --name oracle-23ai \
  -p 1521:1521 -p 2484:2484 -p 8080:8080 \
  container-registry.oracle.com/database/free:23.5.0.0

# Verificar estado del contenedor
docker ps
docker exec -it oracle-23ai sqlplus system/oracle@//localhost:1521/FREE
```

### Verificar Conexión a Oracle
```bash
# Usando SQL*Plus desde el contenedor
docker exec -it oracle-23ai sqlplus system/oracle@//localhost:1521/FREE

# Verificar que la base de datos esté funcionando
SQL> SELECT status FROM v$instance;
SQL> SELECT name FROM v$database;
SQL> EXIT;
```
