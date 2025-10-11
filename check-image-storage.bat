@echo off
echo ========================================
echo 📸 CHECKING IMAGE STORAGE & DATABASE
echo ========================================

echo.
echo 📋 Step 1: Checking uploads directory structure...
docker-compose -f docker-compose.prod.yml exec backend ls -la /app/uploads/

echo.
echo 📋 Step 2: Checking employee folders...
docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -type d -name "*" 2>nul

echo.
echo 📋 Step 3: Finding all captured images...
docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -type f -name "*.jpg" -exec ls -la {} \;

echo.
echo 📋 Step 4: Checking database for image paths...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 Checking employee records for image paths...');
    
    const employees = await Employee.find({});
    console.log('📊 Total employees found:', employees.length);
    
    employees.forEach((emp, index) => {
      console.log('\n👤 Employee', index + 1, ':', emp.name, '(' + emp.email + ')');
      
      if (emp.attendance && emp.attendance.today) {
        const today = emp.attendance.today;
        console.log('   📅 Today check-in image:', today.checkInImage || 'None');
        console.log('   📅 Today check-out image:', today.checkOutImage || 'None');
      }
      
      if (emp.attendance && emp.attendance.records && emp.attendance.records.length > 0) {
        console.log('   📚 Recent records with images:');
        emp.attendance.records.slice(-3).forEach((record, i) => {
          if (record.checkInImage || record.checkOutImage) {
            console.log('     Record', i + 1, ':');
            console.log('       Check-in image:', record.checkInImage || 'None');
            console.log('       Check-out image:', record.checkOutImage || 'None');
          }
        });
      }
    });
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 5: Testing image accessibility via Nginx...
curl -k -I https://localhost/uploads/ || echo "❌ Uploads proxy not working"

echo.
echo 📋 Step 6: Checking backend logs for recent uploads...
docker-compose -f docker-compose.prod.yml logs backend --tail=20 | findstr "Saving image\|Created employee folder\|check-in-with-image\|check-out-with-image"

echo.
echo ========================================
echo ✅ IMAGE STORAGE CHECK COMPLETE!
echo ========================================
echo.
echo 📍 Image Storage Paths:
echo   - Backend container: /app/uploads/employees/[EMPLOYEE_ID]/
echo   - Local volume: ./uploads_data (mounted to /app/uploads)
echo   - Web access: https://hzzeinfo.xyz/uploads/employees/[EMPLOYEE_ID]/[FILENAME]
echo.
echo 🎯 Expected Database Paths:
echo   - checkInImage: "/uploads/employees/[EMPLOYEE_ID]/checkin_YYYY-MM-DD_HH-MM-SS.jpg"
echo   - checkOutImage: "/uploads/employees/[EMPLOYEE_ID]/checkout_YYYY-MM-DD_HH-MM-SS.jpg"
echo.
echo 🧪 Admin Panel Access:
echo   - URL: https://hzzeinfo.xyz/attendance-images
echo   - Should show captured images in table format
echo.
pause


