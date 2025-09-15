#!/bin/bash

# Script para limpiar todos los recursos de Kubernetes
set -e

echo "🧹 Limpiando recursos de Kubernetes..."

# Variables
NAMESPACE="expense-app"

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

# Verificar que kubectl esté disponible
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl no está instalado o no está en el PATH"
    exit 1
fi

print_status "Eliminando todos los recursos del namespace ${NAMESPACE}..."
kubectl delete namespace ${NAMESPACE} --ignore-not-found=true

print_status "Esperando a que el namespace se elimine completamente..."
kubectl wait --for=delete namespace/${NAMESPACE} --timeout=60s 2>/dev/null || true

print_status "✅ Limpieza completada!"

print_status "🎉 ¡Todos los recursos han sido eliminados!"
