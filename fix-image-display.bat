@echo off
echo ========================================
echo 🖼️ FIXING IMAGE DISPLAY IN ADMIN PANEL
echo ========================================

echo.
echo 📋 Step 1: Rebuilding frontend with image fixes...
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo.
echo 📋 Step 2: Restarting frontend container...
docker-compose -f docker-compose.prod.yml up -d frontend

echo.
echo 📋 Step 3: Waiting for frontend to start...
timeout /t 15 /nobreak

echo.
echo 📋 Step 4: Testing image access and URLs...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 Checking image paths and accessibility...');
    
    const employees = await Employee.find({});
    
    for (const emp of employees) {
      const today = emp.attendance?.today;
      if (today && (today.checkInImage || today.checkOutImage)) {
        console.log('\n👤 Employee:', emp.name);
        console.log('   ID:', emp._id);
        
        if (today.checkInImage) {
          console.log('   📸 Check-in image path:', today.checkInImage);
          console.log('   🔗 Full URL: https://hzzeinfo.xyz' + today.checkInImage);
          
          // Check if file exists on disk
          const fs = require('fs');
          const path = require('path');
          const fullPath = path.join('/app', today.checkInImage);
          if (fs.existsSync(fullPath)) {
            console.log('   ✅ File exists on disk');
          } else {
            console.log('   ❌ File NOT found on disk:', fullPath);
          }
        }
        
        if (today.checkOutImage) {
          console.log('   📸 Check-out image path:', today.checkOutImage);
          console.log('   🔗 Full URL: https://hzzeinfo.xyz' + today.checkOutImage);
          
          // Check if file exists on disk
          const fs = require('fs');
          const path = require('path');
          const fullPath = path.join('/app', today.checkOutImage);
          if (fs.existsSync(fullPath)) {
            console.log('   ✅ File exists on disk');
          } else {
            console.log('   ❌ File NOT found on disk:', fullPath);
          }
        }
      }
    }
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 5: Testing Nginx uploads proxy...
curl -k -I https://localhost/uploads/ || echo "❌ Uploads proxy not working"

echo.
echo 📋 Step 6: Checking container logs for errors...
docker-compose -f docker-compose.prod.yml logs frontend --tail=10

echo.
echo ========================================
echo ✅ IMAGE DISPLAY FIX APPLIED!
echo ========================================
echo.
echo 🎯 What was fixed:
echo ✅ Added error handling for failed image loads
echo ✅ Added fallback display for missing images
echo ✅ Added debugging logs for image URLs
echo ✅ Rebuilt frontend with latest fixes
echo.
echo 🧪 Test the admin panel now:
echo 1. Open https://hzzeinfo.xyz/attendance-images
echo 2. Open browser Developer Tools (F12)
echo 3. Check Console tab for image URL logs
echo 4. Check Network tab for failed image requests
echo 5. Images should now show as thumbnails or error fallbacks
echo.
echo 🔍 If images still don't show:
echo - Check browser console for error messages
echo - Verify image files exist on disk (shown above)
echo - Test direct image URLs manually
echo.
echo 📸 Expected result:
echo - Small thumbnail images (100x100px) in the table
echo - Clickable images that open full size in new tab
echo - Green border for check-in images
echo - Red border for check-out images
echo.
pause


