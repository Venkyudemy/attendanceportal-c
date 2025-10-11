@echo off
echo ========================================
echo 🚀 DEPLOYING WITH DOCKER COMPOSE FIXES
echo ========================================

echo.
echo 📋 Step 1: Stopping existing containers...
docker-compose -f docker-compose.prod.yml down

echo.
echo 📋 Step 2: Building all services with latest fixes...
docker-compose -f docker-compose.prod.yml build --no-cache

echo.
echo 📋 Step 3: Starting all services with enhanced initialization...
docker-compose -f docker-compose.prod.yml up -d

echo.
echo 📋 Step 4: Waiting for services to initialize...
timeout /t 45 /nobreak

echo.
echo 📋 Step 5: Checking container status...
docker-compose -f docker-compose.prod.yml ps

echo.
echo 📋 Step 6: Checking backend initialization logs...
docker-compose -f docker-compose.prod.yml logs backend --tail=30

echo.
echo 📋 Step 7: Testing API connectivity...
curl -k https://localhost/api/health || echo "❌ API health check failed"

echo.
echo 📋 Step 8: Testing image storage...
docker-compose -f docker-compose.prod.yml exec backend ls -la /app/uploads/employees/ 2>nul || echo "No employees folder yet"

echo.
echo ========================================
echo ✅ DEPLOYMENT WITH FIXES COMPLETE!
echo ========================================
echo.
echo 🎯 What was deployed:
echo ✅ Updated docker-compose configurations
echo ✅ Enhanced backend initialization
echo ✅ Automatic employee database verification
echo ✅ Automatic image path fixing
echo ✅ Uploads directory structure creation
echo ✅ SSL-enabled frontend
echo ✅ Camera capture functionality
echo ✅ Admin panel image display
echo.
echo 🌐 Access your application:
echo - Frontend: https://hzzeinfo.xyz
echo - Admin Panel: https://hzzeinfo.xyz/attendance-images
echo - Backend API: http://localhost:5000
echo.
echo 🧪 Test features:
echo 1. Employee check-in with camera capture
echo 2. Admin panel image display
echo 3. Image thumbnail viewing
echo 4. Full-size image viewing
echo.
echo 🔍 If issues persist:
echo - Check container logs: docker-compose -f docker-compose.prod.yml logs -f
echo - Verify image storage: docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -name "*.jpg"
echo - Test API: curl -k https://localhost/api/health
echo.
pause


