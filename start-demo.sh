#!/bin/bash

echo "🚀 Iniciando Demo Helidon con Oracle Database 23c..."
echo "=================================================="

# Verificar si Podman está ejecutándose
if ! podman info > /dev/null 2>&1; then
    echo "❌ Error: Podman no está ejecutándose"
    echo "   Por favor, inicia Podman"
    exit 1
fi

# Verificar si Podman Compose está disponible
if ! command -v podman-compose &> /dev/null; then
    echo "❌ Error: Podman Compose no está disponible"
    echo "   Por favor, instala Podman Compose o usa 'podman-compose'"
    exit 1
fi

echo "📦 Iniciando Oracle Database 23c Free..."
podman-compose up -d oracle-db

echo "⏳ Esperando a que Oracle Database esté listo..."
echo "   Esto puede tomar 3-5 minutos en la primera ejecución..."

# Esperar a que Oracle esté listo
while ! podman-compose exec -T oracle-db sqlplus -L sys/Oradoc_db1@//localhost:1521/FREE as sysdba -c "SELECT 1 FROM dual" > /dev/null 2>&1; do
    echo "   Esperando... (Ctrl+C para cancelar)"
    sleep 30
done

echo "✅ Oracle Database está listo!"
echo "   Usuario: helidon_user"
echo "   Contraseña: helidon123"
echo "   SID: FREE"
echo "   Puerto: 1521"

echo ""
echo "🔧 Compilando proyecto Helidon..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ Proyecto compilado exitosamente!"
    echo ""
    echo "🚀 Iniciando aplicación Helidon..."
    echo "   La aplicación estará disponible en: http://localhost:8080"
    echo "   Presiona Ctrl+C para detener la aplicación"
    echo ""
    
    java -jar target/demo-helidon-jsonstore.jar
else
    echo "❌ Error al compilar el proyecto"
    exit 1
fi
