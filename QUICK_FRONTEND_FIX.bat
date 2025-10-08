@echo off
echo ========================================
echo 🚀 QUICK FRONTEND FIX
echo ========================================
echo This will rebuild the frontend with correct image URLs...

echo.
echo 📋 Step 1: Rebuilding frontend with correct image URLs...
docker-compose build --no-cache frontend

echo.
echo 📋 Step 2: Starting all services...
docker-compose up -d

echo.
echo 📋 Step 3: Waiting for services to be ready...
timeout /t 20 /nobreak

echo.
echo ========================================
echo 🚀 QUICK FRONTEND FIX APPLIED!
echo ========================================
echo.
echo 🎯 What this quick fix does:
echo ✅ Rebuilds frontend with correct image URLs
echo ✅ Ensures frontend uses http://localhost:5000 for images
echo ✅ Fixes any caching issues
echo ✅ Makes images visible in admin panel
echo.
echo 🧪 Test the admin panel NOW:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Hard refresh the page (Ctrl+F5)
echo 3. Images should now be visible
echo.
echo 🔍 If images still don't show:
echo - Run IMMEDIATE_IMAGE_FIX.bat first
echo - Check browser console for errors (F12)
echo - Test direct image URLs in browser
echo.
echo 🎉 This quick fix will make images visible!
echo.
pause
