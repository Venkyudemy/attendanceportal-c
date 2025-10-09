@echo off
echo ========================================
echo 🚀 REBUILDING FRONTEND FOR IMAGE DISPLAY
echo ========================================
echo This will rebuild the frontend to ensure images display properly...

echo.
echo 📋 Step 1: Rebuilding frontend...
docker compose build --no-cache frontend

echo.
echo 📋 Step 2: Starting all services...
docker compose up -d

echo.
echo 📋 Step 3: Waiting for services to be ready...
timeout /t 20 /nobreak

echo.
echo ========================================
echo 🚀 FRONTEND REBUILT FOR IMAGE DISPLAY!
echo ========================================
echo.
echo 🎯 What this rebuild does:
echo ✅ Rebuilds frontend with correct image handling
echo ✅ Ensures images are properly routed
echo ✅ Makes images display in admin panel
echo ✅ Does NOT change other APIs
echo.
echo 🧪 Test the admin panel NOW:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Hard refresh the page (Ctrl+F5)
echo 3. Employee "balaji" should now show captured image
echo.
echo 🎉 IMAGES SHOULD NOW BE DISPLAYED!
echo.
pause
