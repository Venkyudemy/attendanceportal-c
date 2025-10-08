@echo off
echo ========================================
echo ⚡ QUICK IMAGE DISPLAY FIX
echo ========================================
echo This will quickly fix the image display in admin panel!

echo.
echo 📋 Step 1: Stopping services...
docker-compose down

echo.
echo 📋 Step 2: Rebuilding frontend with image fixes...
docker-compose build --no-cache frontend

echo.
echo 📋 Step 3: Starting services...
docker-compose up -d

echo.
echo 📋 Step 4: Waiting for services...
timeout /t 15 /nobreak

echo.
echo 📋 Step 5: Quick database verification...
docker-compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('⚡ QUICK IMAGE DISPLAY CHECK...');
    
    const employees = await Employee.find({});
    let imagesFound = 0;
    
    for (const emp of employees) {
      if (emp.attendance?.today) {
        const today = emp.attendance.today;
        
        if (today.checkInImage && fs.existsSync(path.join('/app', today.checkInImage))) {
          console.log('✅ Check-in image found for', emp.name, ':', today.checkInImage);
          imagesFound++;
        }
        
        if (today.checkOutImage && fs.existsSync(path.join('/app', today.checkOutImage))) {
          console.log('✅ Check-out image found for', emp.name, ':', today.checkOutImage);
          imagesFound++;
        }
      }
    }
    
    console.log('📊 Total images found:', imagesFound);
    
    if (imagesFound > 0) {
      console.log('🎉 Images should now be visible in admin panel!');
    } else {
      console.log('⚠️ No images found - employee needs to check-in with camera first');
    }
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo ⚡ QUICK IMAGE DISPLAY FIX APPLIED!
echo ========================================
echo.
echo 🎯 What this quick fix does:
echo ✅ Rebuilds frontend with corrected image URLs
echo ✅ Verifies images exist in database and on disk
echo ✅ Makes images visible in admin panel
echo.
echo 🧪 Test NOW:
echo 1. Open admin panel: http://localhost:3000/attendance-images
echo 2. Hard refresh page (Ctrl+F5)
echo 3. Images should now be visible
echo.
echo 🎉 EMPLOYEE CHECK-IN/CHECK-OUT IMAGES SHOULD NOW BE VISIBLE!
echo.
pause
