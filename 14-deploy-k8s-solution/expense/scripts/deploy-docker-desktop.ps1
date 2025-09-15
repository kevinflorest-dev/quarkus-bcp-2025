# Script específico para desplegar en Docker Desktop Kubernetes (Windows PowerShell)
Write-Host "🐳 Desplegando en Docker Desktop Kubernetes..." -ForegroundColor Green

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

# Verificar que Docker Desktop esté corriendo
try {
    $dockerInfo = docker info 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker Desktop no está corriendo. Por favor inicia Docker Desktop."
        exit 1
    }
} catch {
    Write-Error "Docker Desktop no está disponible"
    exit 1
}

# Verificar que kubectl esté disponible
try {
    $null = Get-Command kubectl -ErrorAction Stop
} catch {
    Write-Error "kubectl no está instalado o no está en el PATH"
    exit 1
}

# Verificar que el contexto sea docker-desktop
$currentContext = kubectl config current-context
if ($currentContext -ne "docker-desktop") {
    Write-Warning "El contexto actual no es docker-desktop. Cambiando contexto..."
    kubectl config use-context docker-desktop
}

Write-Status "Construyendo la aplicación..."
if (Test-Path ".\mvnw.cmd") {
    .\mvnw.cmd clean package -DskipTests
} else {
    mvn clean package -DskipTests
}

Write-Status "Construyendo la imagen Docker..."
docker build -t $IMAGE_NAME .

Write-Status "Desplegando la aplicación..."
kubectl apply -k k8s/environments/docker-desktop.yaml

Write-Status "Esperando a que el deployment esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME -n $NAMESPACE

Write-Status "✅ Despliegue en Docker Desktop completado!"

# Mostrar información del servicio
Write-Status "📋 Información del servicio:"
kubectl get svc -n $NAMESPACE

Write-Status "🌐 Para acceder a la aplicación:"
Write-Host "  - kubectl port-forward svc/${APP_NAME}-service 8080:80 -n $NAMESPACE"
Write-Host "  - Luego visita: http://localhost:8080"

Write-Status "🎉 ¡La aplicación está corriendo en Docker Desktop Kubernetes!"
