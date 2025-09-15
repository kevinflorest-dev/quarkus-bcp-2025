# Script específico para desplegar en Oracle Cloud Kubernetes Engine (OKE) - Windows PowerShell
Write-Host "☁️ Desplegando en Oracle Cloud Kubernetes Engine (OKE)..." -ForegroundColor Green

# Variables
$APP_NAME = "expense-app"
$NAMESPACE = "expense-app"
$REGISTRY_URL = "your-registry.ocir.io"  # Cambiar por tu registry de OCI
$IMAGE_NAME = "${REGISTRY_URL}/${APP_NAME}:latest"

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

# Verificar que kubectl esté configurado para OKE
$currentContext = kubectl config current-context
if ($currentContext -notlike "*oke*") {
    Write-Error "El contexto actual de kubectl no parece ser OKE"
    Write-Warning "Asegúrate de tener configurado el acceso a tu cluster OKE"
    Write-Warning "Puedes usar: oci ce cluster create-kubeconfig --cluster-id <cluster-id>"
    exit 1
}

# Verificar que Docker esté disponible
try {
    $null = Get-Command docker -ErrorAction Stop
} catch {
    Write-Error "Docker no está instalado o no está en el PATH"
    exit 1
}

Write-Status "Construyendo la aplicación..."
if (Test-Path ".\mvnw.cmd") {
    .\mvnw.cmd clean package -DskipTests
} else {
    mvn clean package -DskipTests
}

Write-Status "Construyendo la imagen Docker..."
docker build -t $IMAGE_NAME .

Write-Status "Haciendo push de la imagen al registry..."
docker push $IMAGE_NAME

Write-Status "Desplegando la aplicación..."
kubectl apply -k k8s/environments/oke.yaml

Write-Status "Esperando a que el deployment esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME -n $NAMESPACE

Write-Status "✅ Despliegue en OKE completado!"

# Mostrar información del servicio
Write-Status "📋 Información del servicio:"
kubectl get svc -n $NAMESPACE

Write-Status "🌐 Para acceder a la aplicación:"
Write-Host "  1. Configura un LoadBalancer o usa kubectl port-forward:"
Write-Host "     kubectl port-forward svc/${APP_NAME}-service 8080:80 -n $NAMESPACE"
Write-Host "  2. Visita: http://localhost:8080"

Write-Status "🎉 ¡La aplicación está corriendo en OKE!"
