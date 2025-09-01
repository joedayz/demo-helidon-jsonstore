#!/bin/bash

# Script de Pruebas para Demo Helidon con Oracle Database 23c
# Ejemplos de curl para probar todos los endpoints

echo "🧪 Probando Demo Helidon con Oracle Database 23c"
echo "=================================================="

BASE_URL="http://localhost:8081"

# Función para mostrar resultados
show_result() {
    local title="$1"
    local response="$2"
    echo ""
    echo "📋 $title"
    echo "Respuesta:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
}

# 1. Crear Gastos de Prueba
echo ""
echo "🚀 Creando gastos de prueba..."

# Gasto de comida
echo "✅ Creando gasto de comida..."
FOOD_RESPONSE=$(curl -s -X POST "$BASE_URL/expenses" \
  -H "Content-Type: application/json" \
  -d '{"amount": 45.80, "method": "CARD", "category": "FOOD", "description": "Groceries at supermarket"}')

if [ $? -eq 0 ]; then
    echo "✅ Creado: Groceries at supermarket - $45.80"
    FOOD_ID=$(echo "$FOOD_RESPONSE" | jq -r '.id' 2>/dev/null)
else
    echo "❌ Error creando gasto de comida"
fi

# Gasto de transporte
echo "✅ Creando gasto de transporte..."
TRANSPORT_RESPONSE=$(curl -s -X POST "$BASE_URL/expenses" \
  -H "Content-Type: application/json" \
  -d '{"amount": 15.50, "method": "CASH", "category": "TRANSPORT", "description": "Taxi ride"}')

if [ $? -eq 0 ]; then
    echo "✅ Creado: Taxi ride - $15.50"
    TRANSPORT_ID=$(echo "$TRANSPORT_RESPONSE" | jq -r '.id' 2>/dev/null)
else
    echo "❌ Error creando gasto de transporte"
fi

# Gasto de compras
echo "✅ Creando gasto de compras..."
SHOPPING_RESPONSE=$(curl -s -X POST "$BASE_URL/expenses" \
  -H "Content-Type: application/json" \
  -d '{"amount": 89.99, "method": "DEBIT", "category": "SHOPPING", "description": "New shoes"}')

if [ $? -eq 0 ]; then
    echo "✅ Creado: New shoes - $89.99"
    SHOPPING_ID=$(echo "$SHOPPING_RESPONSE" | jq -r '.id' 2>/dev/null)
else
    echo "❌ Error creando gasto de compras"
fi

# Gasto de entretenimiento
echo "✅ Creando gasto de entretenimiento..."
ENTERTAINMENT_RESPONSE=$(curl -s -X POST "$BASE_URL/expenses" \
  -H "Content-Type: application/json" \
  -d '{"amount": 25.00, "method": "CARD", "category": "ENTERTAINMENT", "description": "Movie tickets"}')

if [ $? -eq 0 ]; then
    echo "✅ Creado: Movie tickets - $25.00"
    ENTERTAINMENT_ID=$(echo "$ENTERTAINMENT_RESPONSE" | jq -r '.id' 2>/dev/null)
else
    echo "❌ Error creando gasto de entretenimiento"
fi

# 2. Obtener Todos los Gastos
echo ""
echo "📊 Obteniendo todos los gastos..."
ALL_EXPENSES=$(curl -s "$BASE_URL/expenses")
if [ $? -eq 0 ]; then
    show_result "Todos los Gastos" "$ALL_EXPENSES"
else
    echo "❌ Error obteniendo gastos"
fi

# 3. Obtener Estadísticas
echo ""
echo "📈 Obteniendo estadísticas..."
STATS=$(curl -s "$BASE_URL/expenses/statistics")
if [ $? -eq 0 ]; then
    show_result "Estadísticas Generales" "$STATS"
else
    echo "❌ Error obteniendo estadísticas"
fi

# 4. Consultas por Categoría
echo ""
echo "🏷️ Consultando por categorías..."

for category in "FOOD" "TRANSPORT" "SHOPPING" "ENTERTAINMENT"; do
    echo "Consultando categoría: $category"
    RESPONSE=$(curl -s "$BASE_URL/expenses/category/$category")
    if [ $? -eq 0 ]; then
        show_result "Gastos en $category" "$RESPONSE"
    else
        echo "❌ Error consultando categoría $category"
    fi
done

# 5. Consultas por Método de Pago
echo ""
echo "💳 Consultando por métodos de pago..."

for method in "CARD" "CASH" "DEBIT"; do
    echo "Consultando método: $method"
    RESPONSE=$(curl -s "$BASE_URL/expenses/method/$method")
    if [ $? -eq 0 ]; then
        show_result "Gastos con $method" "$RESPONSE"
    else
        echo "❌ Error consultando método $method"
    fi
done

# 6. Búsqueda por Descripción
echo ""
echo "🔍 Buscando por descripción..."

for term in "restaurant" "shoes" "taxi"; do
    echo "Buscando: '$term'"
    RESPONSE=$(curl -s "$BASE_URL/expenses/search?q=$term")
    if [ $? -eq 0 ]; then
        show_result "Búsqueda: '$term'" "$RESPONSE"
    else
        echo "❌ Error buscando '$term'"
    fi
done

# 7. Rango de Montos
echo ""
echo "💰 Consultando por rango de montos..."
RANGE_RESPONSE=$(curl -s "$BASE_URL/expenses/amount-range?min=10&max=50")
if [ $? -eq 0 ]; then
    show_result "Gastos entre $10 y $50" "$RANGE_RESPONSE"
else
    echo "❌ Error consultando rango de montos"
fi

# 8. Totales por Categoría
echo ""
echo "📊 Obteniendo totales por categoría..."

for category in "FOOD" "TRANSPORT" "SHOPPING" "ENTERTAINMENT"; do
    echo "Obteniendo total de: $category"
    RESPONSE=$(curl -s "$BASE_URL/expenses/total/category/$category")
    if [ $? -eq 0 ]; then
        show_result "Total en $category" "$RESPONSE"
    else
        echo "❌ Error obteniendo total de $category"
    fi
done

# 9. Totales por Método de Pago
echo ""
echo "💳 Obteniendo totales por método de pago..."

for method in "CARD" "CASH" "DEBIT"; do
    echo "Obteniendo total de: $method"
    RESPONSE=$(curl -s "$BASE_URL/expenses/total/method/$method")
    if [ $? -eq 0 ]; then
        show_result "Total con $method" "$RESPONSE"
    else
        echo "❌ Error obteniendo total de $method"
    fi
done

# 10. Obtener un Gasto Específico (si hay gastos creados)
if [ ! -z "$FOOD_ID" ]; then
    echo ""
    echo "🔍 Obteniendo gasto específico..."
    RESPONSE=$(curl -s "$BASE_URL/expenses/$FOOD_ID")
    if [ $? -eq 0 ]; then
        show_result "Gasto ID: $FOOD_ID" "$RESPONSE"
    else
        echo "❌ Error obteniendo gasto ID $FOOD_ID"
    fi
fi

echo ""
echo "🎉 ¡Pruebas completadas!"
echo "Revisa los resultados arriba para verificar que todo funcione correctamente."
echo ""
echo "💡 Consejos:"
echo "- Si hay errores, verifica que la aplicación esté ejecutándose en el puerto 8081"
echo "- Verifica que Oracle Database esté funcionando"
echo "- Revisa los logs de la aplicación si hay problemas"
echo "- Instala 'jq' para mejor formato de JSON: sudo apt install jq (Ubuntu) o brew install jq (macOS)"
