@echo off
echo ========================================
echo 🔍 TESTING IMAGE FILES
echo ========================================
echo Checking if image files actually exist on disk...

echo.
echo 📋 Step 1: Starting backend...
docker compose up -d backend
timeout /t 15 /nobreak

echo.
echo 📋 Step 2: Testing image files for employee balaji...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 TESTING IMAGE FILES FOR BALAJI...');
    
    // Find employee balaji
    const emp = await Employee.findOne({ name: 'balaji' });
    if (!emp) {
      console.log('❌ Employee balaji not found');
      process.exit(1);
    }
    
    console.log('👤 Found employee:', emp.name);
    console.log('🆔 Employee ID:', emp._id.toString());
    
    // Check attendance data
    if (emp.attendance?.today) {
      const today = emp.attendance.today;
      console.log('\n📊 Attendance data:');
      console.log('  🕐 Check-in time:', today.checkIn);
      console.log('  🕐 Check-out time:', today.checkOut);
      console.log('  📸 Check-in image path:', today.checkInImage);
      console.log('  📸 Check-out image path:', today.checkOutImage);
      
      // Check if check-in image file exists
      if (today.checkInImage) {
        const fullPath = path.join('/app', today.checkInImage);
        console.log('\n🔍 CHECKING CHECK-IN IMAGE:');
        console.log('  📁 Database path:', today.checkInImage);
        console.log('  📁 Full disk path:', fullPath);
        console.log('  ✅ File exists:', fs.existsSync(fullPath));
        
        if (fs.existsSync(fullPath)) {
          const stats = fs.statSync(fullPath);
          console.log('  📊 File size:', stats.size, 'bytes');
          console.log('  📅 Last modified:', stats.mtime);
          console.log('  🎯 IMAGE FILE EXISTS - SHOULD DISPLAY!');
        } else {
          console.log('  ❌ IMAGE FILE NOT FOUND - THIS IS THE PROBLEM!');
          
          // Check what files are actually in the directory
          const empId = emp._id.toString();
          const empDir = path.join('/app/uploads/employees', empId);
          console.log('\n🔍 CHECKING EMPLOYEE DIRECTORY:');
          console.log('  📁 Directory:', empDir);
          console.log('  ✅ Directory exists:', fs.existsSync(empDir));
          
          if (fs.existsSync(empDir)) {
            const files = fs.readdirSync(empDir);
            console.log('  📁 Files in directory:', files);
            
            const imageFiles = files.filter(file => 
              file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg')
            );
            console.log('  📸 Image files:', imageFiles);
            
            if (imageFiles.length > 0) {
              console.log('  🎯 FOUND IMAGE FILES - NEED TO UPDATE DATABASE PATH!');
              console.log('  💡 Correct path should be: /uploads/employees/' + empId + '/' + imageFiles[0]);
            } else {
              console.log('  ❌ NO IMAGE FILES FOUND - IMAGES NOT SAVED PROPERLY');
            }
          } else {
            console.log('  ❌ EMPLOYEE DIRECTORY DOES NOT EXIST');
          }
        }
      }
    }
    
    console.log('\n✅ IMAGE FILE TEST COMPLETE!');
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Test error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo 🔍 IMAGE FILE TEST COMPLETE!
echo ========================================
echo.
echo 💡 Look at the output above to see:
echo 1. Does the image file actually exist on disk?
echo 2. Does the database path match the actual file location?
echo 3. If not, what's the correct path?
echo.
pause
