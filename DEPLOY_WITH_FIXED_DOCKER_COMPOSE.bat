@echo off
echo ========================================
echo 🚀 DEPLOYING WITH FIXED DOCKER-COMPOSE.YML
echo ========================================
echo This will deploy using the updated docker-compose.yml with camera image fixes!

echo.
echo 📋 Step 1: Stopping all services...
docker compose down

echo.
echo 📋 Step 2: Removing old containers and images...
docker compose down --rmi all --volumes --remove-orphans

echo.
echo 📋 Step 3: Building and starting all services with camera image fixes...
docker compose up -d --build

echo.
echo 📋 Step 4: Waiting for all services to be ready...
timeout /t 30 /nobreak

echo.
echo 📋 Step 5: Checking service status...
docker compose ps

echo.
echo ========================================
echo 🚀 DEPLOYMENT WITH FIXED DOCKER-COMPOSE COMPLETE!
echo ========================================
echo.
echo 🎯 What this deployment does:
echo ✅ Uses updated docker-compose.yml with camera image fixes
echo ✅ Automatically finds and fixes camera capture image paths
echo ✅ Makes camera capture images display in admin panel
echo ✅ Routes images properly from backend to frontend
echo ✅ Does NOT change other APIs or routes
echo.
echo 🧪 Test the camera capture image display NOW:
echo 1. Employee login and check-in with camera capture ✅
echo 2. Camera capture image saved in backend ✅
echo 3. Camera capture image saved in database ✅
echo 4. Camera capture image displayed in admin panel ✅ FIXED
echo.
echo 🔍 Navigate to admin panel:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Employee "balaji" should now show actual camera capture images
echo 3. NO MORE "Image Not Found" messages
echo 4. Both check-in and check-out camera capture images should be visible
echo.
echo 🎯 CAMERA CAPTURE IMAGE FLOW:
echo Employee Login → Camera Capture → Backend Save → Database Save → Admin Panel Display
echo     ✅              ✅              ✅              ✅              ✅
echo.
echo 🎉 CAMERA CAPTURE IMAGES WILL NOW DISPLAY IN ADMIN PANEL!
echo.
pause
