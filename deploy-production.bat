@echo off
echo ========================================
echo 🚀 DEPLOYING ATTENDANCE PORTAL TO PRODUCTION
echo ========================================

echo.
echo 📋 Step 1: Stopping existing containers...
docker-compose -f docker-compose.prod.yml down

echo.
echo 📋 Step 2: Building frontend with SSL enabled...
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo.
echo 📋 Step 3: Building backend...
docker-compose -f docker-compose.prod.yml build --no-cache backend

echo.
echo 📋 Step 4: Starting all services...
docker-compose -f docker-compose.prod.yml up -d

echo.
echo 📋 Step 5: Waiting for services to start...
timeout /t 30 /nobreak

echo.
echo 📋 Step 6: Checking container status...
docker-compose -f docker-compose.prod.yml ps

echo.
echo 📋 Step 7: Checking frontend logs...
docker-compose -f docker-compose.prod.yml logs frontend --tail=20

echo.
echo 📋 Step 8: Checking backend logs...
docker-compose -f docker-compose.prod.yml logs backend --tail=20

echo.
echo 📋 Step 9: Testing API connectivity...
curl -k https://localhost/api/health || echo "❌ API health check failed"

echo.
echo ========================================
echo ✅ DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo 🌐 Frontend: https://hzzeinfo.xyz
echo 🔧 Backend: http://localhost:5000
echo 📊 MongoDB: localhost:27017
echo.
echo 📝 Next steps:
echo 1. Check if SSL certificates are in ./certs/ directory
echo 2. Test camera capture functionality
echo 3. Verify employee check-in/check-out with images
echo.
echo 🐛 If issues persist, check logs with:
echo docker-compose -f docker-compose.prod.yml logs -f
echo.
pause