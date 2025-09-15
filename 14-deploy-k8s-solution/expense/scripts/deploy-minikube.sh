#!/bin/bash

# Script específico para desplegar en Minikube
set -e

echo "🐳 Desplegando en Minikube..."

# Variables
APP_NAME="expense-app"
NAMESPACE="expense-app"
IMAGE_NAME="${APP_NAME}:latest"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar que Minikube esté corriendo
if ! minikube status | grep -q "Running"; then
    print_warning "Minikube no está corriendo. Iniciando Minikube..."
    minikube start
fi

# Configurar Docker para usar el daemon de Minikube
print_status "Configurando Docker para usar Minikube..."
eval $(minikube docker-env)

print_status "Construyendo la aplicación..."
./mvnw clean package -DskipTests

print_status "Construyendo la imagen Docker en Minikube..."
docker build -t ${IMAGE_NAME} .

print_status "Desplegando la aplicación..."
kubectl apply -k k8s/

print_status "Esperando a que el deployment esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/${APP_NAME} -n ${NAMESPACE}

print_status "✅ Despliegue en Minikube completado!"

# Abrir la aplicación en el navegador
print_status "🌐 Abriendo la aplicación en el navegador..."
minikube service ${APP_NAME}-service -n ${NAMESPACE}

print_status "🎉 ¡La aplicación está corriendo en Minikube!"
