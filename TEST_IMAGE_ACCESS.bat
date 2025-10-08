@echo off
echo ========================================
echo 🔍 TEST IMAGE ACCESS
echo ========================================
echo Testing if images are accessible...

echo.
echo 📋 Step 1: Starting services...
docker-compose up -d
timeout /t 15 /nobreak

echo.
echo 📋 Step 2: Testing image access...
docker-compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 TESTING IMAGE ACCESS...');
    
    const employees = await Employee.find({});
    
    for (const emp of employees) {
      const today = emp.attendance?.today;
      if (today && (today.checkInImage || today.checkOutImage)) {
        console.log('\n👤 Employee:', emp.name);
        
        if (today.checkInImage) {
          const fullPath = path.join('/app', today.checkInImage);
          const exists = fs.existsSync(fullPath);
          console.log('  📸 Check-in image:', today.checkInImage);
          console.log('  📁 Full path:', fullPath);
          console.log('  ✅ File exists:', exists);
          if (exists) {
            console.log('  🌐 Production URL: https://hzzeinfo.xyz' + today.checkInImage);
            console.log('  🌐 Local URL: http://localhost:5000' + today.checkInImage);
          }
        }
        
        if (today.checkOutImage) {
          const fullPath = path.join('/app', today.checkOutImage);
          const exists = fs.existsSync(fullPath);
          console.log('  📸 Check-out image:', today.checkOutImage);
          console.log('  📁 Full path:', fullPath);
          console.log('  ✅ File exists:', exists);
          if (exists) {
            console.log('  🌐 Production URL: https://hzzeinfo.xyz' + today.checkOutImage);
            console.log('  🌐 Local URL: http://localhost:5000' + today.checkOutImage);
          }
        }
      }
    }
    
    console.log('\n✅ Image access test complete!');
    console.log('💡 Copy any Production URL above and test in your browser');
    console.log('💡 If URLs work but admin panel doesn't show images, there is a frontend issue');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Test error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo 🔍 IMAGE ACCESS TEST COMPLETE!
echo ========================================
echo.
echo 💡 If you see URLs above, copy them and test in your browser
echo 💡 If files exist but URLs don't work, there's a backend serving issue
echo 💡 If no files exist, the image capture isn't saving properly
echo 💡 If URLs work but admin panel doesn't show images, run MAKE_IMAGES_VISIBLE.bat
echo.
pause
