# Script simplificado para verificar el entorno
Write-Host "Verificando entorno..." -ForegroundColor Green

# Verificar Docker/Podman
try {
    docker --version | Out-Null
    Write-Host "Docker: OK" -ForegroundColor Green
} catch {
    try {
        podman --version | Out-Null
        Write-Host "Podman: OK" -ForegroundColor Green
    } catch {
        Write-Host "Docker/Podman: NO ENCONTRADO" -ForegroundColor Red
    }
}

# Verificar kubectl
try {
    kubectl version --client | Out-Null
    Write-Host "kubectl: OK" -ForegroundColor Green
} catch {
    Write-Host "kubectl: NO ENCONTRADO" -ForegroundColor Red
}

# Verificar Java
try {
    java -version | Out-Null
    Write-Host "Java: OK" -ForegroundColor Green
} catch {
    Write-Host "Java: NO ENCONTRADO" -ForegroundColor Red
}

# Verificar Maven Wrapper
if (Test-Path ".\mvnw.cmd") {
    Write-Host "Maven Wrapper: OK" -ForegroundColor Green
} else {
    Write-Host "Maven Wrapper: NO ENCONTRADO" -ForegroundColor Yellow
}

# Verificar archivos del proyecto
if (Test-Path "pom.xml") {
    Write-Host "pom.xml: OK" -ForegroundColor Green
} else {
    Write-Host "pom.xml: NO ENCONTRADO" -ForegroundColor Red
}

if (Test-Path "Dockerfile") {
    Write-Host "Dockerfile: OK" -ForegroundColor Green
} else {
    Write-Host "Dockerfile: NO ENCONTRADO" -ForegroundColor Red
}

Write-Host "Verificacion completada!" -ForegroundColor Green
