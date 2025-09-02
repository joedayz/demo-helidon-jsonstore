# Script de inicio para Windows PowerShell
# Demo Helidon con Oracle Database 23c

Write-Host " Iniciando Demo Helidon con Oracle Database 23c..." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Check if Podman is running
try {
    podman info | Out-Null
} catch {
    Write-Host "❌ Error: Podman is not running" -ForegroundColor Red
    Write-Host "   Please start Podman" -ForegroundColor Yellow
    exit 1
}

# Check if Podman Compose is available
try {
    podman-compose --version | Out-Null
} catch {
    Write-Host "❌ Error: Podman Compose is not available" -ForegroundColor Red
    Write-Host "   Please install Podman Compose or use 'podman-compose'" -ForegroundColor Yellow
    exit 1
}

Write-Host " Iniciando Oracle Database 23c Free..." -ForegroundColor Blue
podman-compose up -d oracle-db

Write-Host "⏳ Waiting for Oracle Database to be ready..." -ForegroundColor Yellow
Write-Host "   This may take 3-5 minutes on first run..." -ForegroundColor Yellow

# Wait for Oracle to be ready
$ready = $false
$attempts = 0
$maxAttempts = 20

while (-not $ready -and $attempts -lt $maxAttempts) {
    $attempts++
    Write-Host "   Attempt $attempts/$maxAttempts - Waiting..." -ForegroundColor Gray
    
    try {
        podman-compose exec -T oracle-db sqlplus -L sys/Oradoc_db1@//localhost:1521/FREE as sysdba -c "SELECT 1 FROM dual" | Out-Null
        $ready = $true
    } catch {
        Start-Sleep -Seconds 30
    }
}

if ($ready) {
    Write-Host "✅ Oracle Database is ready!" -ForegroundColor Green
    Write-Host "   Usuario: helidon_user" -ForegroundColor Cyan
    Write-Host "   Password: helidon123" -ForegroundColor Cyan
    Write-Host "   SID: FREE" -ForegroundColor Cyan
    Write-Host "   Puerto: 1521" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host " Compilando proyecto Helidon..." -ForegroundColor Blue
    
    # Compilar el proyecto
    mvn clean package -DskipTests
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " Proyecto compilado exitosamente!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 Starting Helidon application..." -ForegroundColor Blue
        Write-Host "   The application will be available at: http://localhost:8080" -ForegroundColor Cyan
        Write-Host "   Press Ctrl+C to stop the application" -ForegroundColor Yellow
        Write-Host ""
        
        java -jar target/demo-helidon-jsonstore.jar
    } else {
        Write-Host " Error al compilar el proyecto" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host " Timeout: Oracle Database no se pudo iniciar en el tiempo esperado" -ForegroundColor Red
    Write-Host "   Verifica los logs con: podman-compose logs oracle-db" -ForegroundColor Yellow
    exit 1
}
