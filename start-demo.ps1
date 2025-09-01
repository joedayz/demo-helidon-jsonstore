# Script de inicio para Windows PowerShell
# Demo Helidon con Oracle Database 23c

Write-Host " Iniciando Demo Helidon con Oracle Database 23c..." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Verificar si Podman está ejecutándose
try {
    podman info | Out-Null
} catch {
    Write-Host " Error: Podman no está ejecutándose" -ForegroundColor Red
    Write-Host "   Por favor, inicia Podman" -ForegroundColor Yellow
    exit 1
}

# Verificar si Podman Compose está disponible
try {
    podman-compose --version | Out-Null
} catch {
    Write-Host " Error: Podman Compose no está disponible" -ForegroundColor Red
    Write-Host "   Por favor, instala Podman Compose o usa 'podman-compose'" -ForegroundColor Yellow
    exit 1
}

Write-Host " Iniciando Oracle Database 23c Free..." -ForegroundColor Blue
podman-compose up -d oracle-db

Write-Host " Esperando a que Oracle Database esté listo..." -ForegroundColor Yellow
Write-Host "   Esto puede tomar 3-5 minutos en la primera ejecución..." -ForegroundColor Yellow

# Esperar a que Oracle esté listo
$ready = $false
$attempts = 0
$maxAttempts = 20

while (-not $ready -and $attempts -lt $maxAttempts) {
    $attempts++
    Write-Host "   Intento $attempts/$maxAttempts - Esperando..." -ForegroundColor Gray
    
    try {
        podman-compose exec -T oracle-db sqlplus -L sys/Oradoc_db1@//localhost:1521/FREE as sysdba -c "SELECT 1 FROM dual" | Out-Null
        $ready = $true
    } catch {
        Start-Sleep -Seconds 30
    }
}

if ($ready) {
    Write-Host " Oracle Database está listo!" -ForegroundColor Green
    Write-Host "   Usuario: helidon_user" -ForegroundColor Cyan
    Write-Host "   Contraseña: helidon123" -ForegroundColor Cyan
    Write-Host "   SID: FREE" -ForegroundColor Cyan
    Write-Host "   Puerto: 1521" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host " Compilando proyecto Helidon..." -ForegroundColor Blue
    
    # Compilar el proyecto
    mvn clean package -DskipTests
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " Proyecto compilado exitosamente!" -ForegroundColor Green
        Write-Host ""
        Write-Host " Iniciando aplicación Helidon..." -ForegroundColor Blue
        Write-Host "   La aplicación estará disponible en: http://localhost:8080" -ForegroundColor Cyan
        Write-Host "   Presiona Ctrl+C para detener la aplicación" -ForegroundColor Yellow
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
