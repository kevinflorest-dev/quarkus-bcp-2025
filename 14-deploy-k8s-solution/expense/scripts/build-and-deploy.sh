#!/bin/bash

# Script para construir y desplegar la aplicación en Kubernetes
set -e

echo "🚀 Iniciando construcción y despliegue de la aplicación..."

# Variables
APP_NAME="expense-app"
NAMESPACE="expense-app"
IMAGE_NAME="${APP_NAME}:latest"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que kubectl esté disponible
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl no está instalado o no está en el PATH"
    exit 1
fi

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado o no está en el PATH"
    exit 1
fi

print_status "Construyendo la aplicación con Maven..."
./mvnw clean package -DskipTests

print_status "Construyendo la imagen Docker..."
docker build -t ${IMAGE_NAME} .

print_status "Creando namespace si no existe..."
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

print_status "Desplegando la aplicación..."
kubectl apply -k k8s/

print_status "Esperando a que el deployment esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/${APP_NAME} -n ${NAMESPACE}

print_status "Obteniendo información del servicio..."
kubectl get svc -n ${NAMESPACE}

print_status "✅ Despliegue completado exitosamente!"

# Mostrar información de acceso
echo ""
print_status "📋 Información de acceso:"
echo "  - Namespace: ${NAMESPACE}"
echo "  - Aplicación: ${APP_NAME}"
echo "  - Puerto del servicio: 80"

# Verificar si estamos en Minikube
if kubectl config current-context | grep -q "minikube"; then
    print_status "🔍 Detectado Minikube - ejecutando 'minikube service'..."
    minikube service ${APP_NAME}-service -n ${NAMESPACE}
elif kubectl config current-context | grep -q "oke"; then
    print_warning "Detectado OKE - necesitarás configurar un LoadBalancer o usar kubectl port-forward"
    echo "  Para acceder localmente: kubectl port-forward svc/${APP_NAME}-service 8080:80 -n ${NAMESPACE}"
else
    print_warning "Para acceder a la aplicación:"
    echo "  - kubectl port-forward svc/${APP_NAME}-service 8080:80 -n ${NAMESPACE}"
    echo "  - Luego visita: http://localhost:8080"
fi

echo ""
print_status "🎉 ¡La aplicación está lista!"
