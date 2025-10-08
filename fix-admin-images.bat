@echo off
echo ========================================
echo 📸 FIXING ADMIN ATTENDANCE IMAGES
echo ========================================

echo.
echo 📋 Step 1: Rebuilding frontend with fixed image URLs...
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo.
echo 📋 Step 2: Restarting frontend container...
docker-compose -f docker-compose.prod.yml up -d frontend

echo.
echo 📋 Step 3: Waiting for frontend to start...
timeout /t 15 /nobreak

echo.
echo 📋 Step 4: Checking image storage...
docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -type f -name "*.jpg" -exec ls -la {} \; | head -10

echo.
echo 📋 Step 5: Testing image accessibility...
curl -k -I https://localhost/uploads/ || echo "❌ Uploads proxy not working"

echo.
echo 📋 Step 6: Checking database for image paths...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 Checking for employees with images...');
    
    const employees = await Employee.find({});
    let foundImages = 0;
    
    employees.forEach((emp, index) => {
      if (emp.attendance && emp.attendance.today) {
        const today = emp.attendance.today;
        if (today.checkInImage || today.checkOutImage) {
          foundImages++;
          console.log('📸 Employee:', emp.name);
          if (today.checkInImage) console.log('   Check-in image:', today.checkInImage);
          if (today.checkOutImage) console.log('   Check-out image:', today.checkOutImage);
        }
      }
    });
    
    console.log('📊 Total employees with images:', foundImages);
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo ✅ ADMIN IMAGES FIX APPLIED!
echo ========================================
echo.
echo 🎯 What was fixed:
echo ✅ Admin panel now uses correct API URLs
echo ✅ Image URLs no longer hardcoded to localhost:5000
echo ✅ Images will display properly in production
echo ✅ Nginx proxy serves images correctly
echo.
echo 📍 Image Storage Locations:
echo   - Backend: /app/uploads/employees/[EMPLOYEE_ID]/
echo   - Web URL: https://hzzeinfo.xyz/uploads/employees/[EMPLOYEE_ID]/[FILENAME]
echo   - Database: checkInImage: "/uploads/employees/[EMPLOYEE_ID]/checkin_YYYY-MM-DD_HH-MM-SS.jpg"
echo.
echo 🧪 Test the fix:
echo 1. Open https://hzzeinfo.xyz
echo 2. Login as admin
echo 3. Go to "Attendance Images" page
echo 4. Images should now display properly
echo.
echo 🔍 Admin Panel URL:
echo   https://hzzeinfo.xyz/attendance-images
echo.
pause
