@echo off
echo ========================================
echo 🔍 VERIFYING CAMERA CAPTURE FIXES
echo ========================================

echo.
echo 📋 Step 1: Checking if env-config.js is properly loaded...
docker-compose -f docker-compose.prod.yml exec frontend sh -c "ls -la /usr/share/nginx/html/env*.js"

echo.
echo 📋 Step 2: Checking Nginx configuration...
docker-compose -f docker-compose.prod.yml exec frontend sh -c "cat /etc/nginx/conf.d/default.conf | grep -A 10 'location /api'"

echo.
echo 📋 Step 3: Checking uploads directory...
docker-compose -f docker-compose.prod.yml exec backend sh -c "ls -la /app/uploads/"

echo.
echo 📋 Step 4: Testing API endpoints...
curl -k https://localhost/api/health
echo.

echo.
echo 📋 Step 5: Checking backend environment variables...
docker-compose -f docker-compose.prod.yml exec backend sh -c "env | grep -E '(FRONTEND_ORIGIN|MAX_FILE_SIZE|UPLOAD_PATH)'"

echo.
echo 📋 Step 6: Testing uploads proxy...
curl -k -I https://localhost/uploads/
echo.

echo.
echo ========================================
echo ✅ VERIFICATION COMPLETE!
echo ========================================
echo.
echo 🎯 Key fixes applied:
echo ✅ API service now reads window.env.REACT_APP_API_URL
echo ✅ SSL Nginx template includes /uploads/ proxy
echo ✅ Frontend Dockerfile properly copies env-config.js
echo ✅ Docker-compose includes FRONTEND_ORIGIN for CORS
echo.
echo 🧪 Manual testing needed:
echo 1. Open https://hzzeinfo.xyz in browser
echo 2. Login as employee (email: your-email@domain.com)
echo 3. Try camera capture for check-in/check-out
echo 4. Check if images appear in admin panel
echo.
pause
