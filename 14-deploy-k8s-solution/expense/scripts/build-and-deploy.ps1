# Script para construir y desplegar la aplicación en Kubernetes (Windows PowerShell)
param(
    [string]$Environment = "minikube"
)

Write-Host "🚀 Iniciando construcción y despliegue de la aplicación..." -ForegroundColor Green

# Variables
$APP_NAME = "expense-app"
$NAMESPACE = "expense-app"
$IMAGE_NAME = "${APP_NAME}:latest"

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

# Verificar que Docker esté disponible
try {
    $null = Get-Command docker -ErrorAction Stop
} catch {
    Write-Error "Docker no está instalado o no está en el PATH"
    exit 1
}

Write-Status "Construyendo la aplicación con Maven..."
if (Test-Path ".\mvnw.cmd") {
    .\mvnw.cmd clean package -DskipTests
} else {
    mvn clean package -DskipTests
}

Write-Status "Construyendo la imagen Docker..."
docker build -t $IMAGE_NAME .

Write-Status "Creando namespace si no existe..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

Write-Status "Desplegando la aplicación..."
kubectl apply -k k8s/

Write-Status "Esperando a que el deployment esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME -n $NAMESPACE

Write-Status "Obteniendo información del servicio..."
kubectl get svc -n $NAMESPACE

Write-Status "✅ Despliegue completado exitosamente!"

# Mostrar información de acceso
Write-Host ""
Write-Status "📋 Información de acceso:"
Write-Host "  - Namespace: $NAMESPACE"
Write-Host "  - Aplicación: $APP_NAME"
Write-Host "  - Puerto del servicio: 80"

# Verificar el contexto actual
$currentContext = kubectl config current-context
if ($currentContext -like "*minikube*") {
    Write-Status "🔍 Detectado Minikube - ejecutando 'minikube service'..."
    minikube service ${APP_NAME}-service -n $NAMESPACE
} elseif ($currentContext -like "*oke*") {
    Write-Warning "Detectado OKE - necesitarás configurar un LoadBalancer o usar kubectl port-forward"
    Write-Host "  Para acceder localmente: kubectl port-forward svc/${APP_NAME}-service 8080:80 -n $NAMESPACE"
} else {
    Write-Warning "Para acceder a la aplicación:"
    Write-Host "  - kubectl port-forward svc/${APP_NAME}-service 8080:80 -n $NAMESPACE"
    Write-Host "  - Luego visita: http://localhost:8080"
}

Write-Host ""
Write-Status "🎉 ¡La aplicación está lista!"
