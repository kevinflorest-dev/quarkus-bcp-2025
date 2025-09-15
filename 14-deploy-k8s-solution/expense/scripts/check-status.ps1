# Script para verificar el estado de la aplicación desplegada (Windows PowerShell)
param(
    [string]$Namespace = "expense-app"
)

Write-Host "📊 Verificando estado de la aplicación..." -ForegroundColor Green

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

Write-Host ""
Write-Host "=== Estado del Namespace ===" -ForegroundColor Cyan
kubectl get namespace $Namespace

Write-Host ""
Write-Host "=== Estado de los Pods ===" -ForegroundColor Cyan
kubectl get pods -n $Namespace

Write-Host ""
Write-Host "=== Estado de los Deployments ===" -ForegroundColor Cyan
kubectl get deployments -n $Namespace

Write-Host ""
Write-Host "=== Estado de los Services ===" -ForegroundColor Cyan
kubectl get services -n $Namespace

Write-Host ""
Write-Host "=== Estado del Ingress ===" -ForegroundColor Cyan
kubectl get ingress -n $Namespace

Write-Host ""
Write-Host "=== Estado del LoadBalancer (si existe) ===" -ForegroundColor Cyan
kubectl get service -l app=expense-app -n $Namespace

Write-Host ""
Write-Host "=== Logs del Pod Principal ===" -ForegroundColor Cyan
$pods = kubectl get pods -n $Namespace -o jsonpath='{.items[0].metadata.name}' 2>$null
if ($pods) {
    Write-Status "Mostrando logs del pod: $pods"
    kubectl logs $pods -n $Namespace --tail=20
} else {
    Write-Warning "No se encontraron pods en el namespace $Namespace"
}

Write-Host ""
Write-Host "=== Información de Conexión ===" -ForegroundColor Cyan

# Verificar si hay un LoadBalancer
$loadBalancer = kubectl get service -n $Namespace -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].status.loadBalancer.ingress[0].ip}' 2>$null
if ($loadBalancer) {
    Write-Status "🌐 LoadBalancer IP: $loadBalancer"
    Write-Host "   Puedes acceder a la aplicación en: http://$loadBalancer" -ForegroundColor Yellow
} else {
    Write-Status "🔗 Para acceder localmente, usa port-forward:"
    Write-Host "   kubectl port-forward svc/expense-app-service 8080:80 -n $Namespace" -ForegroundColor Yellow
    Write-Host "   Luego visita: http://localhost:8080" -ForegroundColor Yellow
}

Write-Host ""
Write-Status "✅ Verificación completada!"
