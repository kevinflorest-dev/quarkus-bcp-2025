# Script específico para desplegar en Minikube usando Podman (Windows PowerShell)
Write-Host "🐳 Desplegando en Minikube con Podman..." -ForegroundColor Green

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

# Verificar que Minikube esté corriendo
$minikubeStatus = minikube status
if ($minikubeStatus -notlike "*Running*") {
    Write-Warning "Minikube no está corriendo. Iniciando Minikube..."
    minikube start --container-runtime=containerd
}

# Verificar que Podman esté disponible
try {
    $podmanVersion = podman --version
    Write-Status "Podman detectado: $podmanVersion"
} catch {
    Write-Error "Podman no está disponible"
    exit 1
}

# Configurar Minikube para usar Podman
Write-Status "Configurando Minikube para usar Podman..."
minikube config set container-runtime containerd

Write-Status "Construyendo la aplicación..."
if (Test-Path ".\mvnw.cmd") {
    .\mvnw.cmd clean package -DskipTests
} else {
    mvn clean package -DskipTests
}

Write-Status "Construyendo la imagen con Podman..."
podman build -t $IMAGE_NAME .

Write-Status "Cargando la imagen en Minikube..."
minikube image load $IMAGE_NAME

Write-Status "Desplegando la aplicación..."
kubectl apply -k k8s/

Write-Status "Esperando a que el deployment esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME -n $NAMESPACE

Write-Status "✅ Despliegue en Minikube con Podman completado!"

# Abrir la aplicación en el navegador
Write-Status "🌐 Abriendo la aplicación en el navegador..."
minikube service ${APP_NAME}-service -n $NAMESPACE

Write-Status "🎉 ¡La aplicación está corriendo en Minikube con Podman!"
