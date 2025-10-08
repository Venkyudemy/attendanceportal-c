@echo off
echo ========================================
echo 🚀 DEPLOYING ATTENDANCE PORTAL - PRODUCTION
echo ========================================

echo.
echo 📋 Step 1: Checking SSL certificates...
if not exist "certs\server.crt" (
    echo ❌ SSL certificate not found at ./certs/server.crt
    echo 🔧 Please ensure SSL certificates are in ./certs/ directory:
    echo    - server.crt (SSL certificate)
    echo    - server.key (SSL private key)
    echo.
    echo 💡 Generate self-signed certificates with:
    echo    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/server.key -out certs/server.crt
    pause
    exit /b 1
) else (
    echo ✅ SSL certificates found
)

echo.
echo 📋 Step 2: Stopping existing containers...
docker-compose -f docker-compose.prod.yml down

echo.
echo 📋 Step 3: Building frontend with SSL enabled...
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo.
echo 📋 Step 4: Building backend...
docker-compose -f docker-compose.prod.yml build --no-cache backend

echo.
echo 📋 Step 5: Starting all services...
docker-compose -f docker-compose.prod.yml up -d

echo.
echo 📋 Step 6: Waiting for services to start...
timeout /t 30 /nobreak

echo.
echo 📋 Step 7: Checking container status...
docker-compose -f docker-compose.prod.yml ps

echo.
echo 📋 Step 8: Verifying employee database...
docker-compose -f docker-compose.prod.yml exec backend node check-employee.js

echo.
echo 📋 Step 9: Testing API connectivity...
curl -k https://localhost/api/health || echo "❌ API health check failed"

echo.
echo 📋 Step 10: Checking logs...
docker-compose -f docker-compose.prod.yml logs frontend --tail=10
echo.
docker-compose -f docker-compose.prod.yml logs backend --tail=10

echo.
echo ========================================
echo ✅ PRODUCTION DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo 🌐 Frontend: https://hzzeinfo.xyz
echo 🔧 Backend: http://localhost:5000
echo 📊 MongoDB: localhost:27017
echo.
echo 📝 Production features:
echo ✅ HTTPS with SSL certificates
echo ✅ Camera capture for check-in/check-out
echo ✅ Image upload and storage
echo ✅ Admin panel with attendance images
echo ✅ Employee management
echo.
echo 🧪 Test camera capture:
echo 1. Open https://hzzeinfo.xyz
echo 2. Login as employee
echo 3. Click "Check In" - camera should open
echo 4. Capture photo - should save successfully
echo 5. Check admin panel for captured images
echo.
echo 🐛 If issues, check logs:
echo docker-compose -f docker-compose.prod.yml logs -f
echo.
pause
