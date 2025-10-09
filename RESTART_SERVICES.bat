@echo off
echo ========================================
echo 🔧 RESTARTING SERVICES WITH FIXES
echo ========================================
echo This will restart services with proper initialization...

echo.
echo 📋 Step 1: Stopping all services...
docker compose down

echo.
echo 📋 Step 2: Removing any stuck containers...
docker container prune -f

echo.
echo 📋 Step 3: Starting MongoDB first...
docker compose up -d mongo

echo.
echo 📋 Step 4: Waiting for MongoDB to be healthy...
timeout /t 30 /nobreak

echo.
echo 📋 Step 5: Starting backend with simplified initialization...
docker compose up -d backend

echo.
echo 📋 Step 6: Waiting for backend to be ready...
timeout /t 20 /nobreak

echo.
echo 📋 Step 7: Starting frontend...
docker compose up -d frontend

echo.
echo 📋 Step 8: Checking service status...
docker compose ps

echo.
echo ========================================
echo 🔧 SERVICES RESTARTED WITH FIXES!
echo ========================================
echo.
echo 🎯 What this restart does:
echo ✅ Stops all services cleanly
echo ✅ Removes stuck containers
echo ✅ Starts MongoDB with health checks
echo ✅ Starts backend with simplified initialization
echo ✅ Starts frontend after backend is ready
echo ✅ Includes camera capture image fixes
echo ✅ Uses employee name-based folders
echo.
echo 🧪 Test the services:
echo 1. Backend: http://localhost:5000/api/health
echo 2. Frontend: http://localhost:3000
echo 3. Admin panel: http://localhost:3000/attendance-images
echo.
echo 🔍 Check logs if needed:
echo - Backend: docker compose logs backend -f
echo - Frontend: docker compose logs frontend -f
echo - MongoDB: docker compose logs mongo -f
echo.
pause
