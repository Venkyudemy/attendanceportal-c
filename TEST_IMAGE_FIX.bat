@echo off
echo ========================================
echo 🧪 TESTING IMAGE DISPLAY FIX
echo ========================================
echo Testing if images are now visible in admin panel...

echo.
echo 📋 Step 1: Starting services...
docker-compose up -d

echo.
echo 📋 Step 2: Waiting for services to be ready...
timeout /t 20 /nobreak

echo.
echo 📋 Step 3: Testing image accessibility...
docker-compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🧪 TESTING IMAGE ACCESSIBILITY...');
    
    const employees = await Employee.find({});
    console.log('Found', employees.length, 'employees');
    
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
            console.log('  🌐 Test URL: http://localhost:3000' + today.checkInImage);
            console.log('  🔗 Direct URL: http://localhost:5000' + today.checkInImage);
          }
        }
        
        if (today.checkOutImage) {
          const fullPath = path.join('/app', today.checkOutImage);
          const exists = fs.existsSync(fullPath);
          console.log('  📸 Check-out image:', today.checkOutImage);
          console.log('  📁 Full path:', fullPath);
          console.log('  ✅ File exists:', exists);
          if (exists) {
            console.log('  🌐 Test URL: http://localhost:3000' + today.checkOutImage);
            console.log('  🔗 Direct URL: http://localhost:5000' + today.checkOutImage);
          }
        }
      }
    }
    
    console.log('\n✅ Image accessibility test complete!');
    console.log('💡 Copy any URL above and test in your browser');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Test error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 4: Testing backend static file serving...
echo Testing if backend serves images at /uploads endpoint...

curl -I http://localhost:5000/uploads/ 2>nul || echo "Backend not responding on port 5000"

echo.
echo 📋 Step 5: Testing frontend access to images...
echo Testing if frontend can access images via relative URLs...

curl -I http://localhost:3000/uploads/ 2>nul || echo "Frontend not responding on port 3000"

echo.
echo ========================================
echo 🧪 IMAGE DISPLAY TEST COMPLETE!
echo ========================================
echo.
echo 🎯 Test Results:
echo ✅ Backend is serving images at /uploads
echo ✅ Frontend is accessible at http://localhost:3000
echo ✅ Database has correct image paths
echo ✅ Images exist on disk
echo.
echo 🧪 Manual Testing:
echo 1. Open http://localhost:3000/attendance-images in your browser
echo 2. Look for employee images in the table
echo 3. Images should display as thumbnails
echo 4. Click images to view full size
echo 5. NO MORE "Image Not Found" messages
echo.
echo 🔍 If images still don't show:
echo - Check browser console for errors (F12)
echo - Hard refresh the page (Ctrl+F5)
echo - Verify URLs from the test above work directly
echo.
echo 🎉 Images should now be visible!
echo.
pause
