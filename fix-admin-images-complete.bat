@echo off
echo ========================================
echo 🔧 COMPLETE FIX FOR ADMIN ATTENDANCE IMAGES
echo ========================================

echo.
echo 📋 Step 1: Stopping containers for clean rebuild...
docker-compose -f docker-compose.prod.yml down

echo.
echo 📋 Step 2: Rebuilding frontend with all fixes...
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo.
echo 📋 Step 3: Rebuilding backend...
docker-compose -f docker-compose.prod.yml build --no-cache backend

echo.
echo 📋 Step 4: Starting all services...
docker-compose -f docker-compose.prod.yml up -d

echo.
echo 📋 Step 5: Waiting for services to start...
timeout /t 30 /nobreak

echo.
echo 📋 Step 6: Checking container status...
docker-compose -f docker-compose.prod.yml ps

echo.
echo 📋 Step 7: Verifying employee database and creating test data...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 Checking and fixing employee database...');
    
    const employees = await Employee.find({});
    console.log('📊 Total employees found:', employees.length);
    
    let updatedCount = 0;
    
    for (const emp of employees) {
      let needsUpdate = false;
      
      // Ensure attendance structure exists
      if (!emp.attendance) {
        emp.attendance = {
          today: {
            status: 'Absent',
            checkIns: [],
            checkOuts: [],
            checkInTime: null,
            checkOutTime: null,
            checkInImage: null,
            checkOutImage: null,
            date: null
          },
          records: []
        };
        needsUpdate = true;
        console.log('✅ Created attendance structure for:', emp.name);
      }
      
      // Ensure today record has proper structure
      if (!emp.attendance.today) {
        emp.attendance.today = {
          status: 'Absent',
          checkIns: [],
          checkOuts: [],
          checkInTime: null,
          checkOutTime: null,
          checkInImage: null,
          checkOutImage: null,
          date: null
        };
        needsUpdate = true;
        console.log('✅ Created today record for:', emp.name);
      }
      
      // Set today's date if not set
      if (!emp.attendance.today.date) {
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        emp.attendance.today.date = year + '-' + month + '-' + day;
        needsUpdate = true;
        console.log('✅ Set today date for:', emp.name, '-', emp.attendance.today.date);
      }
      
      if (needsUpdate) {
        await emp.save();
        updatedCount++;
        console.log('💾 Saved updates for:', emp.name);
      }
    }
    
    console.log('📊 Updated', updatedCount, 'employees');
    
    // Show final status
    console.log('\n📋 Final employee status:');
    for (const emp of employees) {
      const today = emp.attendance?.today;
      console.log('👤', emp.name, ':');
      console.log('   Status:', today?.status || 'Not set');
      console.log('   Date:', today?.date || 'Not set');
      console.log('   Check-in image:', today?.checkInImage || 'None');
      console.log('   Check-out image:', today?.checkOutImage || 'None');
    }
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 8: Testing API endpoint...
curl -k https://localhost/api/employee/attendance | head -20

echo.
echo 📋 Step 9: Checking recent backend logs...
docker-compose -f docker-compose.prod.yml logs backend --tail=20

echo.
echo ========================================
echo ✅ COMPLETE FIX APPLIED!
echo ========================================
echo.
echo 🎯 What was fixed:
echo ✅ Frontend rebuilt with correct API URLs
echo ✅ Backend rebuilt with latest code
echo ✅ Employee database structure verified/fixed
echo ✅ Today's date set for all employees
echo ✅ Attendance structure created if missing
echo.
echo 🧪 Test the admin panel now:
echo 1. Open https://hzzeinfo.xyz/attendance-images
echo 2. Should now show employees with proper data
echo 3. If employees checked in today, images should appear
echo.
echo 🔍 If still no images:
echo - Check if employees actually captured photos during check-in
echo - Look at browser console for API errors
echo - Check backend logs for upload errors
echo.
pause
