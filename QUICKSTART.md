# 🚀 Inicio Rápido - Demo Helidon con Oracle Database 23c

## 📋 Prerrequisitos

- ✅ Podman instalado y ejecutándose
- ✅ Podman Compose disponible
- ✅ Java 21+ instalado
- ✅ Maven instalado

## 🎯 Inicio en 3 Pasos

### 1. Clonar el Repositorio
```bash
git clone <tu-repositorio>
cd demo-helidon-jsonstore
```

### 2. Ejecutar el Script de Inicio

**Linux/macOS:**
```bash
chmod +x start-demo.sh
./start-demo.sh
```

**Windows:**
```powershell
.\start-demo.ps1
```

### 3. ¡Listo! 🎉

La aplicación estará disponible en: **http://localhost:8081**

## 🔍 Verificar que Todo Funcione

### Verificar Base de Datos
```bash
# Ver logs de Oracle
podman-compose logs oracle-db

# Conectar a la base de datos
podman-compose exec oracle-db sqlplus C##helidon_user/helidon123@//localhost:1521/FREE
```

### Verificar Aplicación

**Opción 1: Pruebas Manuales**

**Linux/macOS (curl):**
```bash
# Probar endpoint de salud
curl http://localhost:8081/health

# Crear un gasto de prueba
curl -X POST http://localhost:8081/expenses \
  -H "Content-Type: application/json" \
  -d '{"amount": 25.50, "method": "CARD", "category": "FOOD", "description": "Lunch"}'
```

**Windows (PowerShell):**
```powershell
# Probar endpoint de salud
Invoke-RestMethod -Uri "http://localhost:8081/health" -Method GET

# Crear un gasto de prueba
Invoke-RestMethod -Uri "http://localhost:8081/expenses" -Method POST -ContentType "application/json" -Body '{"amount": 25.50, "method": "CARD", "category": "FOOD", "description": "Lunch"}'
```

**Opción 2: Pruebas Automatizadas (Recomendado)**

**Windows:**
```powershell
.\test-examples.ps1
```

**Linux/macOS:**
```bash
./test-examples.sh
```

## 🛠️ Comandos Útiles

### Gestión de Contenedores
```bash
# Iniciar solo la base de datos
podman-compose up -d oracle-db

# Detener todo
podman-compose down

# Ver logs en tiempo real
podman-compose logs -f oracle-db

# Reiniciar base de datos
podman-compose restart oracle-db
```

### Debugging
```bash
# Acceder al contenedor de Oracle
podman-compose exec oracle-db bash

# Cliente SQL*Plus para debugging
podman-compose --profile debug up sqlplus-client

# Ver logs de la aplicación
podman-compose logs -f oracle-db
```

### Limpieza
```bash
# Eliminar contenedores y volúmenes
podman-compose down -v

# Eliminar imágenes
podman rmi container-registry.oracle.com/database/free:23.5.0.0
```

## 🚨 Solución de Problemas

### Oracle Database no inicia
```bash
# Ver logs detallados
podman-compose logs oracle-db

# Verificar recursos del sistema
podman stats oracle-23ai

# Reiniciar Podman
```

### Error de Conexión
```bash
# Verificar que Oracle esté listo
podman-compose exec oracle-db sqlplus -L sys/Oradoc_db1@//localhost:1521/FREE as sysdba -c "SELECT 1 FROM dual"

# Verificar puertos
netstat -an | grep 1521
```

### Error de Compilación
```bash
# Limpiar y recompilar
mvn clean package -DskipTests

# Verificar Java y Maven
java -version
mvn -version
```

## 📚 Recursos Adicionales

- [README Completo](README-ORACLE-JSON.md)
- [Documentación de Oracle Database 23c](https://docs.oracle.com/en/database/oracle/oracle-database/23/)
- [Helidon MicroProfile](https://helidon.io/docs/v4/#/mp/introduction)

## 🆘 Soporte

Si tienes problemas:
1. Verifica los logs: `podman-compose logs oracle-db`
2. Revisa este documento
3. Consulta el README completo
4. Abre un issue en el repositorio

---

**¡Disfruta explorando Oracle Database 23c con Helidon! 🎉**
