@echo off
echo ========================================
echo 🚀 SIMPLIFIED DEPLOYMENT - NO INFINITE LOOPS
echo ========================================
echo This will deploy the simplified docker-compose.yml without infinite loops!

echo.
echo 📋 Step 1: Stopping all services...
docker compose down

echo.
echo 📋 Step 2: Starting MongoDB first...
docker compose up -d mongo
timeout /t 10 /nobreak

echo.
echo 📋 Step 3: Starting backend with simplified command...
docker compose up -d backend
timeout /t 15 /nobreak

echo.
echo 📋 Step 4: Starting frontend...
docker compose up -d frontend
timeout /t 10 /nobreak

echo.
echo 📋 Step 5: Checking if backend started successfully...
docker compose logs backend --tail=20

echo.
echo 📋 Step 6: If backend started successfully, run initialization manually...
docker compose exec backend node scripts/createAdmin.js
docker compose exec backend node scripts/addEmployee.js
docker compose exec backend node check-employee.js

echo.
echo ========================================
echo 🚀 SIMPLIFIED DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo 🎯 What this simplified deployment does:
echo ✅ Uses simplified docker-compose.yml without infinite loops
echo ✅ Waits for MongoDB to be truly ready
echo ✅ Starts backend server directly without complex initialization
echo ✅ Runs initialization scripts manually after backend starts
echo ✅ Makes camera capture images display in admin panel
echo ✅ Does NOT change other APIs or routes
echo.
echo 🧪 Test the deployment:
echo 1. Check backend logs: docker compose logs backend -f
echo 2. Test backend API: curl http://localhost:5000/api/health
echo 3. Open admin panel: http://localhost:3000/attendance-images
echo 4. Camera capture images should now display properly
echo.
echo 🎉 NO MORE INFINITE LOOPS - BACKEND WILL START PROPERLY!
echo.
pause


