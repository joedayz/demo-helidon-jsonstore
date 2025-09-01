# Script de Pruebas para Demo Helidon con Oracle Database 23c
# Ejemplos de PowerShell para probar todos los endpoints

Write-Host "Probando Demo Helidon con Oracle Database 23c" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

$baseUrl = "http://localhost:8081"

# Funcion para mostrar resultados
function Show-Result {
    param($Title, $Response)
    Write-Host "`n$Title" -ForegroundColor Cyan
    Write-Host "Respuesta:" -ForegroundColor Yellow
    $Response | ConvertTo-Json -Depth 3
}

# 1. Crear Gastos de Prueba
Write-Host "`nCreando gastos de prueba..." -ForegroundColor Blue

$expenses = @(
    @{
        amount = 45.80
        method = "CARD"
        category = "FOOD"
        description = "Groceries at supermarket"
    },
    @{
        amount = 15.50
        method = "CASH"
        category = "TRANSPORT"
        description = "Taxi ride"
    },
    @{
        amount = 89.99
        method = "DEBIT"
        category = "SHOPPING"
        description = "New shoes"
    },
    @{
        amount = 25.00
        method = "CARD"
        category = "ENTERTAINMENT"
        description = "Movie tickets"
    }
)

$createdExpenses = @()

foreach ($expense in $expenses) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/expenses" -Method POST -ContentType "application/json" -Body ($expense | ConvertTo-Json)
        $createdExpenses += $response
        Write-Host "Creado: $($expense.description) - $($expense.amount)" -ForegroundColor Green
    } catch {
        Write-Host "Error creando: $($expense.description)" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 2. Obtener Todos los Gastos
Write-Host "`nObteniendo todos los gastos..." -ForegroundColor Blue
try {
    $allExpenses = Invoke-RestMethod -Uri "$baseUrl/expenses" -Method GET
    Show-Result "Todos los Gastos" $allExpenses
} catch {
    Write-Host "Error obteniendo gastos: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Obtener Estadisticas
Write-Host "`nObteniendo estadisticas..." -ForegroundColor Blue
try {
    $stats = Invoke-RestMethod -Uri "$baseUrl/expenses/statistics" -Method GET
    Show-Result "Estadisticas Generales" $stats
} catch {
    Write-Host "Error obteniendo estadisticas: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Consultas por Categoria
Write-Host "`nConsultando por categorias..." -ForegroundColor Blue
$categories = @("FOOD", "TRANSPORT", "SHOPPING", "ENTERTAINMENT")

foreach ($category in $categories) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/expenses/category/$category" -Method GET
        Show-Result "Gastos en $($category)" $response
    } catch {
        Write-Host "Error consultando categoria $($category): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 5. Consultas por Metodo de Pago
Write-Host "`nConsultando por metodos de pago..." -ForegroundColor Blue
$methods = @("CARD", "CASH", "DEBIT")

foreach ($method in $methods) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/expenses/method/$method" -Method GET
        Show-Result "Gastos con $($method)" $response
    } catch {
        Write-Host "Error consultando metodo $($method): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 6. Busqueda por Descripcion
Write-Host "`nBuscando por descripcion..." -ForegroundColor Blue
$searchTerms = @("restaurant", "shoes", "taxi")

foreach ($term in $searchTerms) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/expenses/search?q=$term" -Method GET
        Show-Result "Busqueda: '$term'" $response
    } catch {
        Write-Host "Error buscando '$term': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 7. Rango de Montos
Write-Host "`nConsultando por rango de montos..." -ForegroundColor Blue
try {
    $url = "$baseUrl/expenses/amount-range?min=10&max=50"
    $response = Invoke-RestMethod -Uri $url -Method GET
    Show-Result "Gastos entre 10 y 50" $response
} catch {
    Write-Host "Error consultando rango de montos: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. Totales por Categoria
Write-Host "`nObteniendo totales por categoria..." -ForegroundColor Blue
foreach ($category in $categories) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/expenses/total/category/$category" -Method GET
        Show-Result "Total en $($category)" $response
    } catch {
        Write-Host "Error obteniendo total de $($category): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 9. Totales por Metodo de Pago
Write-Host "`nObteniendo totales por metodo de pago..." -ForegroundColor Blue
foreach ($method in $methods) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/expenses/total/method/$method" -Method GET
        Show-Result "Total con $($method)" $response
    } catch {
        Write-Host "Error obteniendo total de $($method): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 10. Obtener un Gasto Especifico (si hay gastos creados)
if ($createdExpenses.Count -gt 0) {
    Write-Host "`nObteniendo gasto especifico..." -ForegroundColor Blue
    $firstExpenseId = $createdExpenses[0].id
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/expenses/$firstExpenseId" -Method GET
        Show-Result "Gasto ID: $firstExpenseId" $response
    } catch {
        Write-Host "Error obteniendo gasto ID $($firstExpenseId): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nPruebas completadas!" -ForegroundColor Green
Write-Host "Revisa los resultados arriba para verificar que todo funcione correctamente." -ForegroundColor Yellow
Write-Host "`nConsejos:" -ForegroundColor Cyan
Write-Host "- Si hay errores, verifica que la aplicacion este ejecutandose en el puerto 8081" -ForegroundColor White
Write-Host "- Verifica que Oracle Database este funcionando" -ForegroundColor White
Write-Host "- Revisa los logs de la aplicacion si hay problemas" -ForegroundColor White
