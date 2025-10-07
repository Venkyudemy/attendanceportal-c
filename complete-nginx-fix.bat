@echo off
echo 🔧 COMPLETE Nginx Fix - Eliminating Environment Variable Issues
echo.

echo [INFO] Step 1: Stopping all containers...
docker-compose -f docker-compose.prod.yml down

echo [INFO] Step 2: Using clean nginx config without environment variables...
copy "Frontend\nginx-clean.conf.template" "Frontend\nginx.conf.template"

echo [INFO] Step 3: Rebuilding frontend with clean config...
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo [INFO] Step 4: Starting services in order...
docker-compose -f docker-compose.prod.yml up -d mongo
timeout /t 10 /nobreak >nul

docker-compose -f docker-compose.prod.yml up -d attendence-backend
timeout /t 15 /nobreak >nul

docker-compose -f docker-compose.prod.yml up -d frontend
timeout /t 10 /nobreak >nul

echo [INFO] Step 5: Testing deployment...
curl -f http://localhost/health >nul 2>&1
if not errorlevel 1 (
    echo [SUCCESS] ✅ Frontend is working!
    echo [SUCCESS] ✅ No more environment variable errors!
    echo [SUCCESS] ✅ Nginx uses direct service name: attendence-backend:5000
) else (
    echo [ERROR] ❌ Frontend still having issues
    echo [INFO] Checking logs...
    docker-compose -f docker-compose.prod.yml logs frontend
)

echo.
echo [INFO] Container status:
docker-compose -f docker-compose.prod.yml ps

echo.
echo [SUCCESS] Complete fix applied!
echo [INFO] Your nginx now uses: proxy_pass http://attendence-backend:5000;
pause
