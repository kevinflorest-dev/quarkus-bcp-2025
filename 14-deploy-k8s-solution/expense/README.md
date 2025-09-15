# Expense RESTful Service - Kubernetes Agnóstico

Este proyecto usa Quarkus, el Supersonic Subatomic Java Framework, y está configurado para ejecutarse en cualquier cluster de Kubernetes (Minikube, OKE, Docker Desktop, etc.).

## 🚀 Despliegue Rápido (Windows 11)

### Para Docker Desktop Kubernetes (Recomendado para Windows)
```powershell
# Ejecutar en PowerShell como administrador
.\scripts\deploy-docker-desktop.ps1
```

### Para Minikube
```powershell
# Ejecutar en PowerShell
.\scripts\deploy-minikube.ps1
```

### Para Oracle Cloud Kubernetes Engine (OKE)
```powershell
# Configurar acceso a OKE primero
oci ce cluster create-kubeconfig --cluster-id <tu-cluster-id>

# Editar el script para configurar tu registry
# Editar scripts/deploy-oke.ps1 y cambiar REGISTRY_URL

# Desplegar en OKE
.\scripts\deploy-oke.ps1
```

### Para cualquier cluster de Kubernetes
```powershell
.\scripts\build-and-deploy.ps1
```

## 🧹 Limpieza
```powershell
.\scripts\cleanup.ps1
```

## 📁 Estructura del Proyecto

```
├── k8s/                    # Archivos de Kubernetes
│   ├── namespace.yaml      # Namespace para la aplicación
│   ├── configmap.yaml      # Configuraciones de la aplicación
│   ├── deployment.yaml     # Deployment de la aplicación
│   ├── service.yaml        # Service para exponer la aplicación
│   ├── ingress.yaml        # Ingress para acceso externo
│   ├── kustomization.yaml  # Gestión de recursos con Kustomize
│   └── environments/       # Configuraciones específicas por entorno
│       ├── minikube.yaml   # Configuración para Minikube
│       └── docker-desktop.yaml # Configuración para Docker Desktop
├── scripts/                # Scripts de automatización
│   ├── *.ps1              # Scripts de PowerShell para Windows
│   ├── *.sh               # Scripts de Bash (para WSL/Git Bash)
│   ├── build-and-deploy.ps1 # Script general de despliegue
│   ├── deploy-minikube.ps1  # Script específico para Minikube
│   ├── deploy-docker-desktop.ps1 # Script para Docker Desktop
│   ├── deploy-oke.ps1       # Script específico para OKE
│   └── cleanup.ps1          # Script de limpieza
├── Dockerfile              # Dockerfile optimizado para Kubernetes
└── kubefiles/              # Archivos originales de OpenShift (legacy)
```

## 🔧 Configuración

### Variables de Entorno
- `EXPENSE_MAX_AMOUNT`: Monto máximo permitido para gastos (default: 2000)
- `QUARKUS_DATASOURCE_DB_KIND`: Tipo de base de datos (default: h2)
- `QUARKUS_DATASOURCE_JDBC_URL`: URL de conexión a la base de datos
- `QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION`: Estrategia de generación de esquema

### Recursos de Kubernetes
- **Namespace**: `expense-app`
- **Deployment**: `expense-app` con 1 réplica
- **Service**: `expense-app-service` tipo ClusterIP
- **Ingress**: `expense-app-ingress` para acceso externo

## 🌐 Acceso a la Aplicación

### Docker Desktop Kubernetes
```powershell
# Port-forward para acceso local
kubectl port-forward svc/expense-app-service 8080:80 -n expense-app

# Luego visita: http://localhost:8080
```

### Minikube
La aplicación se abrirá automáticamente en tu navegador usando `minikube service`.

### OKE u otros clusters
```powershell
# Port-forward para acceso local
kubectl port-forward svc/expense-app-service 8080:80 -n expense-app

# Luego visita: http://localhost:8080
```

## 🏥 Health Checks
La aplicación incluye health checks configurados:
- **Liveness Probe**: `/q/health/live`
- **Readiness Probe**: `/q/health/ready`

## 📊 Monitoreo
```powershell
# Ver logs de la aplicación
kubectl logs -f deployment/expense-app -n expense-app

# Ver estado de los pods
kubectl get pods -n expense-app

# Ver servicios
kubectl get svc -n expense-app
```

## 🔄 Desarrollo Local

### Ejecutar en modo desarrollo
```powershell
# Usando Maven Wrapper
.\mvnw.cmd compile quarkus:dev

# O usando Maven instalado
mvn compile quarkus:dev
```

### Construir la aplicación
```powershell
.\mvnw.cmd clean package
```

### Construir imagen nativa
```powershell
.\mvnw.cmd package -Pnative
```

## 🖥️ Requisitos para Windows 11

### Software Necesario
1. **Docker Desktop** (con Kubernetes habilitado)
   - Descargar desde: https://www.docker.com/products/docker-desktop
   - Habilitar Kubernetes en Settings > Kubernetes

2. **kubectl**
   - Instalar con Chocolatey: `choco install kubernetes-cli`
   - O descargar desde: https://kubernetes.io/docs/tasks/tools/

3. **Maven** (opcional, se incluye Maven Wrapper)
   - Instalar con Chocolatey: `choco install maven`

4. **PowerShell 7** (recomendado)
   - Instalar desde Microsoft Store o con winget

### Configuración Inicial
```powershell
# Verificar que Docker Desktop esté corriendo
docker info

# Verificar que kubectl esté configurado
kubectl config current-context

# Verificar que Kubernetes esté disponible
kubectl get nodes
```

## 📝 Notas Importantes

1. **Registry de Imágenes**: Para OKE, necesitas configurar tu propio registry de OCI Container Registry
2. **Ingress Controller**: Asegúrate de tener un Ingress Controller instalado en tu cluster
3. **Persistencia**: La aplicación usa H2 en memoria. Para producción, considera usar una base de datos persistente
4. **Seguridad**: Los pods se ejecutan como usuario no-root por seguridad
5. **PowerShell Execution Policy**: Si tienes problemas ejecutando scripts, ejecuta:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## 🆚 Diferencias con OpenShift

| OpenShift | Kubernetes Agnóstico |
|-----------|---------------------|
| Route | Ingress |
| ImageStream | Docker Image |
| BuildConfig | Docker Build |
| SecurityContext específico | SecurityContext estándar |

## 🆘 Troubleshooting

### Problemas comunes en Windows:
1. **Imagen no encontrada**: Asegúrate de que la imagen esté construida y disponible
2. **Ingress no funciona**: Verifica que tengas un Ingress Controller instalado
3. **Pods no inician**: Revisa los logs con `kubectl logs`
4. **Permisos**: Asegúrate de tener permisos para crear recursos en el namespace
5. **Docker Desktop**: Verifica que Kubernetes esté habilitado en Docker Desktop
6. **PowerShell**: Ejecuta PowerShell como administrador si hay problemas de permisos

### Comandos útiles para debugging:
```powershell
# Verificar estado del cluster
kubectl cluster-info

# Verificar nodos
kubectl get nodes

# Verificar namespaces
kubectl get namespaces

# Verificar todos los recursos
kubectl get all -n expense-app

# Ver logs detallados
kubectl describe pod <pod-name> -n expense-app
```

Para más información sobre Quarkus, visita: https://quarkus.io/
