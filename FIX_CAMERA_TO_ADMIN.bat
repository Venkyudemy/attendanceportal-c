@echo off
echo ========================================
echo 🎯 CAMERA CAPTURE TO ADMIN PANEL FIX
echo ========================================
echo This will fix the image routing from camera capture to admin panel!

echo.
echo 📋 Step 1: Fixing database image paths...
node fix-image-paths.js

echo.
echo 📋 Step 2: Starting backend server...
cd Backend
start npm start

echo.
echo 📋 Step 3: Starting frontend...
cd ../Frontend
start npm start

echo.
echo ========================================
echo 🎯 CAMERA TO ADMIN PANEL FIX APPLIED!
echo ========================================
echo.
echo 🎯 What this fix does:
echo ✅ Finds all camera capture images on disk
echo ✅ Updates database paths to point to actual files
echo ✅ Makes images visible in admin panel
echo ✅ Routes camera capture images properly to admin panel
echo.
echo 🧪 Test the fix:
echo 1. Wait for backend and frontend to start
echo 2. Open http://localhost:3000/attendance-images
echo 3. Images should now be visible as thumbnails
echo 4. NO MORE "Image Not Found" messages
echo.
echo 🎉 Camera capture images are now routed to admin panel!
echo.
pause
