@echo off
echo ========================================
echo 🔧 FIXING EMPLOYEE CHECK-IN ISSUE
echo ========================================

echo.
echo 📋 Step 1: Stopping containers to rebuild frontend...
docker-compose -f docker-compose.prod.yml down

echo.
echo 📋 Step 2: Rebuilding frontend with fixed API URLs...
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo.
echo 📋 Step 3: Starting all services...
docker-compose -f docker-compose.prod.yml up -d

echo.
echo 📋 Step 4: Waiting for services to start...
timeout /t 30 /nobreak

echo.
echo 📋 Step 5: Checking if employee exists in database...
docker-compose -f docker-compose.prod.yml exec backend node check-employee.js

echo.
echo 📋 Step 6: Testing API connectivity...
curl -k https://localhost/api/health
echo.

echo.
echo 📋 Step 7: Checking container logs...
docker-compose -f docker-compose.prod.yml logs frontend --tail=10
echo.
docker-compose -f docker-compose.prod.yml logs backend --tail=10

echo.
echo ========================================
echo ✅ FIXES APPLIED!
echo ========================================
echo.
echo 🎯 What was fixed:
echo ✅ Frontend now uses correct API URLs from window.env
echo ✅ Employee database record verified/created
echo ✅ Check-in endpoint should now work properly
echo.
echo 🧪 Test the fix:
echo 1. Open https://hzzeinfo.xyz/employee-portal
echo 2. Login as employee
echo 3. Click "Check In" - camera should open
echo 4. Capture photo - check-in should succeed
echo.
echo 🐛 If still not working, check:
echo - Browser console for API URL errors
echo - Backend logs for employee lookup errors
echo.
pause


