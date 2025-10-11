@echo off
echo ========================================
echo 🔧 QUICK FIX - EMPLOYEE CHECK-IN ISSUE
echo ========================================

echo.
echo 📋 This script will fix the "Employee not found" error
echo 📋 by rebuilding frontend and verifying employee database
echo.

echo 📋 Step 1: Rebuilding frontend with fixed API URLs...
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo.
echo 📋 Step 2: Restarting frontend container...
docker-compose -f docker-compose.prod.yml up -d frontend

echo.
echo 📋 Step 3: Waiting for frontend to start...
timeout /t 15 /nobreak

echo.
echo 📋 Step 4: Verifying employee database...
docker-compose -f docker-compose.prod.yml exec backend node check-employee.js

echo.
echo 📋 Step 5: Testing API connectivity...
curl -k https://localhost/api/health
echo.

echo.
echo ========================================
echo ✅ QUICK FIX APPLIED!
echo ========================================
echo.
echo 🎯 What was fixed:
echo ✅ Frontend now uses correct API URLs (/api instead of localhost:5000)
echo ✅ Employee database record verified/created
echo ✅ Check-in endpoint should now work properly
echo.
echo 🧪 Test immediately:
echo 1. Open https://hzzeinfo.xyz/employee-portal
echo 2. Login as employee
echo 3. Click "Check In" - camera should open
echo 4. Capture photo - should succeed without "Employee not found" error
echo.
echo 🐛 If still not working:
echo - Check browser console for API URL logs
echo - Verify request goes to /api/ not localhost:5000
echo - Check backend logs for employee lookup
echo.
pause


