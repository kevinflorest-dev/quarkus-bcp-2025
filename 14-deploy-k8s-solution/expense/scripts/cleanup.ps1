# Script para limpiar todos los recursos de Kubernetes (Windows PowerShell)
Write-Host "🧹 Limpiando recursos de Kubernetes..." -ForegroundColor Green

# Variables
$NAMESPACE = "expense-app"

# Función para imprimir mensajes con colores
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Verificar que kubectl esté disponible
try {
    $null = Get-Command kubectl -ErrorAction Stop
} catch {
    Write-Error "kubectl no está instalado o no está en el PATH"
    exit 1
}

Write-Status "Eliminando todos los recursos del namespace $NAMESPACE..."
kubectl delete namespace $NAMESPACE --ignore-not-found=true

Write-Status "Esperando a que el namespace se elimine completamente..."
try {
    kubectl wait --for=delete namespace/$NAMESPACE --timeout=60s 2>$null
} catch {
    # Ignorar errores si el namespace ya no existe
}

Write-Status "✅ Limpieza completada!"

Write-Status "🎉 ¡Todos los recursos han sido eliminados!"
