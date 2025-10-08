@echo off
echo ========================================
echo 🚀 DEPLOYING DEV WITH IMAGE FIXES
echo ========================================

echo.
echo 📋 Step 1: Stopping existing containers...
docker-compose down

echo.
echo 📋 Step 2: Building all services with latest fixes...
docker-compose build --no-cache

echo.
echo 📋 Step 3: Starting all services with enhanced initialization...
docker-compose up -d

echo.
echo 📋 Step 4: Waiting for services to initialize...
timeout /t 30 /nobreak

echo.
echo 📋 Step 5: Checking container status...
docker-compose ps

echo.
echo 📋 Step 6: Checking backend initialization logs...
docker-compose logs backend --tail=30

echo.
echo 📋 Step 7: Testing API connectivity...
curl -k http://localhost:5000/api/health || echo "❌ API health check failed"

echo.
echo 📋 Step 8: Testing image storage...
docker-compose exec backend ls -la /app/uploads/employees/ 2>nul || echo "No employees folder yet"

echo.
echo 📋 Step 9: Checking for image files...
docker-compose exec backend find /app/uploads -name "*.jpg" -type f 2>nul || echo "No image files found"

echo.
echo ========================================
echo ✅ DEV DEPLOYMENT WITH IMAGE FIXES COMPLETE!
echo ========================================
echo.
echo 🎯 What was deployed:
echo ✅ Updated docker-compose.yml with image path fixing
echo ✅ Enhanced backend initialization
echo ✅ Automatic employee database verification
echo ✅ Automatic image path fixing
echo ✅ Uploads directory structure creation
echo ✅ Camera capture functionality
echo ✅ Admin panel image display
echo.
echo 🌐 Access your application:
echo - Frontend: http://localhost:3000
echo - Admin Panel: http://localhost:3000/attendance-images
echo - Backend API: http://localhost:5000
echo.
echo 🧪 Test features:
echo 1. Employee check-in with camera capture
echo 2. Admin panel image display
echo 3. Image thumbnail viewing
echo 4. Full-size image viewing
echo.
echo 🔍 Check backend logs for image fixes:
echo docker-compose logs backend | findstr "Fixed.*image path"
echo.
echo 🔍 If issues persist:
echo - Check container logs: docker-compose logs -f
echo - Verify image storage: docker-compose exec backend find /app/uploads -name "*.jpg"
echo - Test API: curl http://localhost:5000/api/health
echo.
pause
