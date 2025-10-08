@echo off
echo ========================================
echo 🧪 TESTING COMPLETE IMAGE FLOW
echo ========================================
echo This will test the complete image flow from capture to display...

echo.
echo 📋 Step 1: Testing backend image serving...
docker-compose exec backend curl -I http://localhost:5000/uploads/ 2>nul || echo "Backend not responding on port 5000"

echo.
echo 📋 Step 2: Testing database image paths...
docker-compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🧪 TESTING IMAGE FLOW...');
    
    const employees = await Employee.find({});
    let foundImages = 0;
    
    for (const emp of employees) {
      if (emp.attendance?.today) {
        const today = emp.attendance.today;
        
        if (today.checkInImage) {
          const fullPath = path.join('/app', today.checkInImage);
          const exists = fs.existsSync(fullPath);
          console.log('👤', emp.name, 'Check-in image:', today.checkInImage, exists ? '✅' : '❌');
          if (exists) foundImages++;
        }
        
        if (today.checkOutImage) {
          const fullPath = path.join('/app', today.checkOutImage);
          const exists = fs.existsSync(fullPath);
          console.log('👤', emp.name, 'Check-out image:', today.checkOutImage, exists ? '✅' : '❌');
          if (exists) foundImages++;
        }
      }
    }
    
    console.log('\n📊 SUMMARY:');
    console.log('Total employees:', employees.length);
    console.log('Total images found:', foundImages);
    
    if (foundImages > 0) {
      console.log('✅ Images are saved and should be visible in admin panel!');
    } else {
      console.log('❌ No images found - employee needs to check-in/out with camera');
    }
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Test error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 3: Testing API endpoint...
docker-compose exec backend curl -s http://localhost:5000/api/employee/attendance | head -c 200
echo ...
echo

echo.
echo 📋 Step 4: Instructions for manual testing...
echo.
echo 🧪 MANUAL TESTING STEPS:
echo 1. Open employee portal: http://localhost:3000/employee-portal
echo 2. Login as employee (e.g., sai@example.com / password123)
echo 3. Click "Check In" button
echo 4. Allow camera access and capture photo
echo 5. Wait for "Check-in successful" message
echo 6. Open admin panel: http://localhost:3000/attendance-images
echo 7. Verify image appears in the table
echo 8. Click image to see full-size preview
echo.
echo 🎯 If images don't show in admin panel:
echo - Check browser console (F12) for errors
echo - Verify employee actually checked in with camera
echo - Run this test script again to verify images exist
echo.
pause
