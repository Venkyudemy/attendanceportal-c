@echo off
echo ========================================
echo 🚀 REBUILDING FRONTEND WITH IMAGE FIXES
echo ========================================
echo This will rebuild the frontend with corrected image URLs...

echo.
echo 📋 Step 1: Rebuilding frontend with image fixes...
docker-compose build --no-cache frontend

echo.
echo 📋 Step 2: Starting all services...
docker-compose up -d

echo.
echo 📋 Step 3: Waiting for services to be ready...
timeout /t 20 /nobreak

echo.
echo ========================================
echo 🚀 FRONTEND REBUILT WITH IMAGE FIXES!
echo ========================================
echo.
echo 🎯 What this rebuild does:
echo ✅ Rebuilds frontend with corrected image URLs
echo ✅ Removes hardcoded localhost:5000 references
echo ✅ Uses relative paths for images (works in Docker)
echo ✅ Makes images properly routed through Nginx
echo.
echo 🧪 Test the admin panel NOW:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Hard refresh the page (Ctrl+F5)
echo 3. Images should now be visible and properly routed
echo.
echo 🔍 The images will now be served through:
echo - Development: http://localhost:5000/uploads/...
echo - Production: https://hzzeinfo.xyz/uploads/...
echo.
echo 🎉 Images should now display correctly!
echo.
pause
