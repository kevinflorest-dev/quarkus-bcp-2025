# Script para probar el despliegue completo (Windows PowerShell)
Write-Host "🧪 Probando despliegue completo..." -ForegroundColor Green

# Variables
$APP_NAME = "expense-app"
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

# Verificar entorno
Write-Status "Verificando entorno..."
.\scripts\check-environment.ps1

# Limpiar despliegue anterior si existe
Write-Status "Limpiando despliegue anterior..."
.\scripts\cleanup.ps1

# Esperar un momento
Start-Sleep -Seconds 2

# Desplegar aplicación
Write-Status "Desplegando aplicación..."
.\scripts\deploy-docker-desktop.ps1

# Esperar a que esté listo
Write-Status "Esperando a que la aplicación esté lista..."
Start-Sleep -Seconds 10

# Verificar estado
Write-Status "Verificando estado de la aplicación..."
.\scripts\check-status.ps1

# Probar la aplicación
Write-Status "Probando la aplicación..."
try {
    # Iniciar port-forward en background
    $portForwardJob = Start-Job -ScriptBlock {
        param($Namespace, $AppName)
        kubectl port-forward svc/${AppName}-service 8080:80 -n $Namespace
    } -ArgumentList $NAMESPACE, $APP_NAME

    # Esperar a que el port-forward esté listo
    Start-Sleep -Seconds 5

    # Probar endpoint de health
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/q/health/ready" -Method GET -TimeoutSec 10
    Write-Status "✅ Health check exitoso: $($healthResponse.status)"

    # Probar endpoint principal
    $mainResponse = Invoke-RestMethod -Uri "http://localhost:8080/" -Method GET -TimeoutSec 10
    Write-Status "✅ Endpoint principal responde correctamente"

    # Detener port-forward
    Stop-Job $portForwardJob
    Remove-Job $portForwardJob

} catch {
    Write-Error "❌ Error probando la aplicación: $($_.Exception.Message)"
    Write-Warning "Asegúrate de que la aplicación esté completamente desplegada"
}

Write-Host ""
Write-Status "🎉 ¡Prueba completada!"
Write-Host ""
Write-Status "Para acceder a la aplicación manualmente:"
Write-Host "  kubectl port-forward svc/expense-app-service 8080:80 -n expense-app" -ForegroundColor Yellow
Write-Host "  Luego visita: http://localhost:8080" -ForegroundColor Yellow
