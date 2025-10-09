@echo off
echo ========================================
echo 🔍 DIAGNOSING CAMERA CAPTURE IMAGE ISSUE
echo ========================================
echo This will diagnose why camera capture images are not displaying...

echo.
echo 📋 Step 1: Checking backend status...
docker compose ps

echo.
echo 📋 Step 2: Checking backend logs...
docker compose logs backend --tail=10

echo.
echo 📋 Step 3: Checking if image files exist on disk...
docker compose exec backend find /app/uploads/employees -maxdepth 2 -type f -name "*.jpg" -printf "File: %p, Size: %s bytes, Last Modified: %t\n" 2>nul

echo.
echo 📋 Step 4: Checking database for image paths...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 CHECKING DATABASE FOR IMAGE PATHS...');
    
    const employees = await Employee.find({});
    console.log('Found', employees.length, 'employees in database');
    
    for (const emp of employees) {
      if (emp.attendance?.today) {
        const today = emp.attendance.today;
        console.log('\n👤 Employee:', emp.name);
        console.log('   📸 Check-in image path:', today.checkInImage || 'NULL');
        console.log('   📸 Check-out image path:', today.checkOutImage || 'NULL');
        console.log('   🕐 Check-in time:', today.checkIn || 'NULL');
        console.log('   🕐 Check-out time:', today.checkOut || 'NULL');
        
        // Check if image files actually exist
        if (today.checkInImage) {
          const fs = require('fs');
          const path = require('path');
          const fullPath = path.join('/app', today.checkInImage);
          const exists = fs.existsSync(fullPath);
          console.log('   📁 Check-in file exists:', exists, '(Path:', fullPath + ')');
        }
        
        if (today.checkOutImage) {
          const fs = require('fs');
          const path = require('path');
          const fullPath = path.join('/app', today.checkOutImage);
          const exists = fs.existsSync(fullPath);
          console.log('   📁 Check-out file exists:', exists, '(Path:', fullPath + ')');
        }
      }
    }
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database check error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 5: Testing backend API endpoint...
curl -s http://localhost:5000/api/employee/attendance | head -c 500

echo.
echo ========================================
echo 🔍 DIAGNOSIS COMPLETE!
echo ========================================
echo.
echo 💡 Look at the output above to see:
echo 1. Is the backend running properly?
echo 2. Do image files exist on disk?
echo 3. Are image paths stored in database?
echo 4. Do the database paths match actual files?
echo 5. Is the API returning image paths?
echo.
pause
