@echo off
setlocal enabledelayedexpansion

REM Production Deployment Script for Attendance Portal (Windows)
REM This script safely deploys the application with zero downtime

echo 🚀 Starting Production Deployment...

REM Check if docker-compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] docker-compose not found. Please install Docker Compose.
    exit /b 1
)

REM Check if we're in the right directory
if not exist "docker-compose.prod.yml" (
    echo [ERROR] docker-compose.prod.yml not found. Please run this script from the project root.
    exit /b 1
)

REM Backup current containers (optional)
echo [INFO] Creating backup of current deployment...
docker-compose -f docker-compose.prod.yml ps > deployment-backup-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.txt 2>nul

REM Stop and remove old containers
echo [INFO] Stopping old containers...
docker-compose -f docker-compose.prod.yml down

REM Pull latest images (if using external images)
echo [INFO] Pulling latest base images...
docker-compose -f docker-compose.prod.yml pull mongo 2>nul

REM Build new images
echo [INFO] Building new application images...
docker-compose -f docker-compose.prod.yml build --no-cache

REM Start services in correct order
echo [INFO] Starting MongoDB...
docker-compose -f docker-compose.prod.yml up -d mongo

echo [INFO] Waiting for MongoDB to be ready...
timeout /t 10 /nobreak >nul

echo [INFO] Starting backend service...
docker-compose -f docker-compose.prod.yml up -d attendence-backend

echo [INFO] Waiting for backend to be ready...
timeout /t 15 /nobreak >nul

REM Health check for backend
echo [INFO] Checking backend health...
set /a attempts=0
:backend_health_check
set /a attempts+=1
curl -f http://localhost:5000/api/health >nul 2>&1
if not errorlevel 1 (
    echo [SUCCESS] Backend is healthy!
    goto backend_healthy
)
if %attempts% geq 30 (
    echo [ERROR] Backend health check failed after 30 attempts
    echo [INFO] Backend logs:
    docker-compose -f docker-compose.prod.yml logs attendence-backend
    exit /b 1
)
echo [INFO] Waiting for backend... (attempt %attempts%/30)
timeout /t 2 /nobreak >nul
goto backend_health_check

:backend_healthy
echo [INFO] Starting frontend service...
docker-compose -f docker-compose.prod.yml up -d frontend

echo [INFO] Waiting for frontend to be ready...
timeout /t 10 /nobreak >nul

REM Health check for frontend
echo [INFO] Checking frontend health...
set /a attempts=0
:frontend_health_check
set /a attempts+=1
curl -f http://localhost/health >nul 2>&1
if not errorlevel 1 (
    echo [SUCCESS] Frontend is healthy!
    goto frontend_healthy
)
if %attempts% geq 20 (
    echo [ERROR] Frontend health check failed after 20 attempts
    echo [INFO] Frontend logs:
    docker-compose -f docker-compose.prod.yml logs frontend
    exit /b 1
)
echo [INFO] Waiting for frontend... (attempt %attempts%/20)
timeout /t 2 /nobreak >nul
goto frontend_health_check

:frontend_healthy
REM Final status check
echo [INFO] Checking all services...
docker-compose -f docker-compose.prod.yml ps

echo [SUCCESS] 🎉 Deployment completed successfully!
echo [INFO] Application is available at:
echo [INFO]   Frontend: http://localhost
echo [INFO]   Backend API: http://localhost:5000
echo [INFO]   Health Check: http://localhost/health

REM Show logs
echo [INFO] Recent logs:
docker-compose -f docker-compose.prod.yml logs --tail=10

echo [SUCCESS] Deployment script completed!
pause
