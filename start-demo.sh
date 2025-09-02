#!/bin/bash

echo "🚀 Iniciando Demo Helidon con Oracle Database 23c..."
echo "=================================================="

# Check if Podman is running
if ! podman info > /dev/null 2>&1; then
    echo "❌ Error: Podman is not running"
    echo "   Please start Podman"
    exit 1
fi

# Check if Podman Compose is available
if ! command -v podman-compose &> /dev/null; then
    echo "❌ Error: Podman Compose is not available"
    echo "   Please install Podman Compose or use 'podman-compose'"
    exit 1
fi

echo "📦 Iniciando Oracle Database 23c Free..."
podman-compose up -d oracle-db

echo "⏳ Waiting for Oracle Database to be ready..."
echo "   This may take 3-5 minutes on first run..."

# Wait for Oracle to be ready
while ! podman-compose exec -T oracle-db sqlplus -L sys/Oradoc_db1@//localhost:1521/FREE as sysdba -c "SELECT 1 FROM dual" > /dev/null 2>&1; do
    echo "   Waiting... (Ctrl+C to cancel)"
    sleep 30
done

echo "✅ Oracle Database is ready!"
echo "   User: helidon_user"
echo "   Password: helidon123"
echo "   SID: FREE"
echo "   Port: 1521"

echo ""
echo "🔧 Compilando proyecto Helidon..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ Project compiled successfully!"
    echo ""
    echo "🚀 Starting Helidon application..."
    echo "   The application will be available at: http://localhost:8080"
    echo "   Press Ctrl+C to stop the application"
    echo ""
    
    java -jar target/demo-helidon-jsonstore.jar
else
    echo "❌ Error al compilar el proyecto"
    exit 1
fi
