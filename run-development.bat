@echo off
echo ========================================
echo 🚀 RUNNING ATTENDANCE PORTAL - DEVELOPMENT
echo ========================================

echo.
echo 📋 Step 1: Stopping existing containers...
docker-compose down

echo.
echo 📋 Step 2: Building all services...
docker-compose build --no-cache

echo.
echo 📋 Step 3: Starting all services...
docker-compose up -d

echo.
echo 📋 Step 4: Waiting for services to start...
timeout /t 20 /nobreak

echo.
echo 📋 Step 5: Checking container status...
docker-compose ps

echo.
echo 📋 Step 6: Checking logs...
docker-compose logs frontend --tail=10
echo.
docker-compose logs backend --tail=10

echo.
echo ========================================
echo ✅ DEVELOPMENT ENVIRONMENT READY!
echo ========================================
echo.
echo 🌐 Frontend: http://localhost:3000
echo 🔧 Backend: http://localhost:5000
echo 📊 MongoDB: localhost:27017
echo.
echo 📝 Features available:
echo ✅ Camera capture for check-in/check-out
echo ✅ Image upload and storage
echo ✅ Admin panel with attendance images
echo ✅ Employee management
echo.
echo 🧪 Test camera capture:
echo 1. Open http://localhost:3000
echo 2. Login as employee
echo 3. Click "Check In" - camera should open
echo 4. Capture photo - should save successfully
echo.
echo 🐛 If issues, check logs:
echo docker-compose logs -f
echo.
pause
