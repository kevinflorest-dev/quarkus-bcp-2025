# Script para verificar que el entorno esté correctamente configurado (Windows PowerShell)
Write-Host "🔍 Verificando configuración del entorno..." -ForegroundColor Green

# Variables
$allGood = $true

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
    $script:allGood = $false
}

function Test-Command {
    param([string]$Command, [string]$Description)
    
    try {
        $null = Get-Command $Command -ErrorAction Stop
        Write-Status "✅ $Description está instalado"
        return $true
    } catch {
        Write-Error "❌ $Description no está instalado o no está en el PATH"
        return $false
    }
}

function Test-Docker {
    try {
        $dockerInfo = docker info 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Status "✅ Docker Desktop está corriendo"
            return $true
        } else {
            Write-Error "❌ Docker Desktop no está corriendo"
            return $false
        }
    } catch {
        Write-Error "❌ Docker Desktop no está disponible"
        return $false
    }
}

function Test-Kubernetes {
    try {
        $kubectlVersion = kubectl version --client 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Status "✅ kubectl está disponible"
            
            # Verificar conexión al cluster
            $clusterInfo = kubectl cluster-info 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Status "✅ Conectado al cluster Kubernetes"
                
                # Mostrar contexto actual
                $currentContext = kubectl config current-context
                Write-Status "📋 Contexto actual: $currentContext"
                
                # Mostrar nodos
                $nodes = kubectl get nodes 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Status "✅ Cluster tiene nodos disponibles"
                } else {
                    Write-Warning "⚠️ No se pueden obtener los nodos del cluster"
                }
                
                return $true
            } else {
                Write-Error "❌ No se puede conectar al cluster Kubernetes"
                return $false
            }
        } else {
            Write-Error "❌ kubectl no está funcionando correctamente"
            return $false
        }
    } catch {
        Write-Error "❌ Error verificando Kubernetes"
        return $false
    }
}

function Test-Maven {
    if (Test-Path ".\mvnw.cmd") {
        Write-Status "✅ Maven Wrapper está disponible"
        return $true
    } else {
        try {
            $mvnVersion = mvn --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Status "✅ Maven está instalado"
                return $true
            } else {
                Write-Warning "⚠️ Maven no está instalado, pero se puede usar Maven Wrapper"
                return $true
            }
        } catch {
            Write-Warning "⚠️ Maven no está instalado, pero se puede usar Maven Wrapper"
            return $true
        }
    }
}

function Test-Java {
    try {
        $javaVersion = java -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "✅ Java está instalado"
            return $true
        } else {
            Write-Error "❌ Java no está instalado o no está en el PATH"
            return $false
        }
    } catch {
        Write-Error "❌ Java no está disponible"
        return $false
    }
}

# Verificaciones
Write-Host ""
Write-Host "=== Verificando herramientas necesarias ===" -ForegroundColor Cyan

Test-Command "docker" "Docker"
Test-Command "kubectl" "kubectl"
Test-Maven
Test-Java

Write-Host ""
Write-Host "=== Verificando servicios ===" -ForegroundColor Cyan

Test-Docker
Test-Kubernetes

Write-Host ""
Write-Host "=== Verificando archivos del proyecto ===" -ForegroundColor Cyan

if (Test-Path "pom.xml") {
    Write-Status "✅ pom.xml encontrado"
} else {
    Write-Error "❌ pom.xml no encontrado"
}

if (Test-Path "Dockerfile") {
    Write-Status "✅ Dockerfile encontrado"
} else {
    Write-Error "❌ Dockerfile no encontrado"
}

if (Test-Path "k8s") {
    Write-Status "✅ Directorio k8s encontrado"
} else {
    Write-Error "❌ Directorio k8s no encontrado"
}

if (Test-Path "scripts") {
    Write-Status "✅ Directorio scripts encontrado"
} else {
    Write-Error "❌ Directorio scripts no encontrado"
}

Write-Host ""
Write-Host "=== Resumen ===" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "🎉 ¡Todo está configurado correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Puedes proceder con el despliegue usando:" -ForegroundColor Yellow
    Write-Host "  .\scripts\deploy-docker-desktop.ps1" -ForegroundColor White
    Write-Host "  .\scripts\deploy-minikube.ps1" -ForegroundColor White
    Write-Host "  .\scripts\build-and-deploy.ps1" -ForegroundColor White
} else {
    Write-Host "⚠️ Hay problemas en la configuración que necesitan ser resueltos." -ForegroundColor Red
    Write-Host ""
    Write-Host "Revisa los errores arriba y asegúrate de:" -ForegroundColor Yellow
    Write-Host "  1. Tener Docker Desktop instalado y corriendo" -ForegroundColor White
    Write-Host "  2. Tener kubectl instalado" -ForegroundColor White
    Write-Host "  3. Tener Java instalado" -ForegroundColor White
    Write-Host "  4. Estar en el directorio correcto del proyecto" -ForegroundColor White
}

Write-Host ""
