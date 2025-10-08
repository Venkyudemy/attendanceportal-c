@echo off
echo ========================================
echo 🔍 CHECKING IMAGE STATUS
echo ========================================
echo This will check what's happening with the images...

echo.
echo 📋 Step 1: Checking if services are running...
docker compose ps

echo.
echo 📋 Step 2: Checking backend logs for image uploads...
docker compose logs backend | findstr /c:"📸 Saving image:" /c:"✅ Created employee folder:" | tail -n 10

echo.
echo 📋 Step 3: Checking what image files exist on disk...
docker compose exec backend find /app/uploads/employees -maxdepth 2 -type f -name "*.jpg" -printf "File: %p, Size: %s bytes, Last Modified: %t\n" 2>nul

echo.
echo 📋 Step 4: Checking database for image paths...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 Checking database for image paths...');
    
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
echo ========================================
echo 🔍 IMAGE STATUS CHECK COMPLETE!
echo ========================================
echo.
echo 💡 Look at the output above to see:
echo 1. Are image files being created on disk?
echo 2. Are image paths being saved in database?
echo 3. Are the paths pointing to existing files?
echo.
pause
