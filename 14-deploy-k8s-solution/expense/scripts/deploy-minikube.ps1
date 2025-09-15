# Script específico para desplegar en Minikube (Windows PowerShell)
Write-Host "🐳 Desplegando en Minikube..." -ForegroundColor Green

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

# Verificar que Minikube esté corriendo
$minikubeStatus = minikube status
if ($minikubeStatus -notlike "*Running*") {
    Write-Warning "Minikube no está corriendo. Iniciando Minikube..."
    minikube start
}

# Configurar Docker para usar el daemon de Minikube
Write-Status "Configurando Docker para usar Minikube..."
& minikube docker-env | Invoke-Expression

Write-Status "Construyendo la aplicación..."
if (Test-Path ".\mvnw.cmd") {
    .\mvnw.cmd clean package -DskipTests
} else {
    mvn clean package -DskipTests
}

Write-Status "Construyendo la imagen Docker en Minikube..."
docker build -t $IMAGE_NAME .

Write-Status "Desplegando la aplicación..."
kubectl apply -k k8s/

Write-Status "Esperando a que el deployment esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME -n $NAMESPACE

Write-Status "✅ Despliegue en Minikube completado!"

# Abrir la aplicación en el navegador
Write-Status "🌐 Abriendo la aplicación en el navegador..."
minikube service ${APP_NAME}-service -n $NAMESPACE

Write-Status "🎉 ¡La aplicación está corriendo en Minikube!"
