#!/bin/bash

# Script específico para desplegar en Oracle Cloud Kubernetes Engine (OKE)
set -e

echo "☁️ Desplegando en Oracle Cloud Kubernetes Engine (OKE)..."

# Variables
APP_NAME="expense-app"
NAMESPACE="expense-app"
REGISTRY_URL="your-registry.ocir.io"  # Cambiar por tu registry de OCI
IMAGE_NAME="${REGISTRY_URL}/${APP_NAME}:latest"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que kubectl esté configurado para OKE
if ! kubectl config current-context | grep -q "oke"; then
    print_error "El contexto actual de kubectl no parece ser OKE"
    print_warning "Asegúrate de tener configurado el acceso a tu cluster OKE"
    print_warning "Puedes usar: oci ce cluster create-kubeconfig --cluster-id <cluster-id>"
    exit 1
fi

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado o no está en el PATH"
    exit 1
fi

print_status "Construyendo la aplicación..."
./mvnw clean package -DskipTests

print_status "Construyendo la imagen Docker..."
docker build -t ${IMAGE_NAME} .

print_status "Haciendo push de la imagen al registry..."
docker push ${IMAGE_NAME}

print_status "Desplegando la aplicación..."
kubectl apply -k k8s/

print_status "Esperando a que el deployment esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/${APP_NAME} -n ${NAMESPACE}

print_status "✅ Despliegue en OKE completado!"

# Mostrar información del servicio
print_status "📋 Información del servicio:"
kubectl get svc -n ${NAMESPACE}

print_status "🌐 Para acceder a la aplicación:"
echo "  1. Configura un LoadBalancer o usa kubectl port-forward:"
echo "     kubectl port-forward svc/${APP_NAME}-service 8080:80 -n ${NAMESPACE}"
echo "  2. Visita: http://localhost:8080"

print_status "🎉 ¡La aplicación está corriendo en OKE!"
