@echo off
echo ========================================
echo 🔍 DEBUGGING ADMIN ATTENDANCE IMAGES
echo ========================================

echo.
echo 📋 Step 1: Checking all employees in database...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 Checking all employees in database...');
    
    const employees = await Employee.find({});
    console.log('📊 Total employees found:', employees.length);
    
    employees.forEach((emp, index) => {
      console.log('\n👤 Employee', index + 1, ':', emp.name, '(' + emp.email + ')');
      console.log('   ID:', emp._id);
      
      if (emp.attendance && emp.attendance.today) {
        const today = emp.attendance.today;
        console.log('   📅 Today attendance:');
        console.log('     Status:', today.status || 'Not set');
        console.log('     Date:', today.date || 'Not set');
        console.log('     Check-in time:', today.checkIn || 'None');
        console.log('     Check-out time:', today.checkOut || 'None');
        console.log('     Check-in image:', today.checkInImage || 'None');
        console.log('     Check-out image:', today.checkOutImage || 'None');
        console.log('     Check-ins array:', today.checkIns || []);
        console.log('     Check-outs array:', today.checkOuts || []);
      } else {
        console.log('   ❌ No attendance.today data');
      }
      
      if (emp.attendance && emp.attendance.records && emp.attendance.records.length > 0) {
        console.log('   📚 Recent records:');
        emp.attendance.records.slice(-2).forEach((record, i) => {
          console.log('     Record', i + 1, ':');
          console.log('       Date:', record.date || 'Not set');
          console.log('       Check-in image:', record.checkInImage || 'None');
          console.log('       Check-out image:', record.checkOutImage || 'None');
        });
      } else {
        console.log('   📚 No attendance records');
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
echo 📋 Step 2: Checking image files on disk...
docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -type f -name "*.jpg" -exec ls -la {} \;

echo.
echo 📋 Step 3: Checking uploads directory structure...
docker-compose -f docker-compose.prod.yml exec backend ls -la /app/uploads/
docker-compose -f docker-compose.prod.yml exec backend ls -la /app/uploads/employees/ 2>nul || echo "No employees folder found"

echo.
echo 📋 Step 4: Testing today's date matching...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const today = new Date();
const year = today.getFullYear();
const month = String(today.getMonth() + 1).padStart(2, '0');
const day = String(today.getDate()).padStart(2, '0');
const todayStr = year + '-' + month + '-' + day;
console.log('📅 Today date string:', todayStr);
console.log('📅 Current time:', today.toISOString());
"

echo.
echo 📋 Step 5: Checking backend logs for recent activity...
docker-compose -f docker-compose.prod.yml logs backend --tail=30 | findstr "check-in\|check-out\|image\|upload\|Saving"

echo.
echo ========================================
echo ✅ DEBUG COMPLETE!
echo ========================================
echo.
echo 🎯 Key findings will show:
echo - Employee database records and image paths
echo - Actual image files on disk
echo - Date matching issues
echo - Recent backend activity
echo.
pause
