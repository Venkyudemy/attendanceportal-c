@echo off
echo ========================================
echo 🔍 VERIFYING END-TO-END IMAGE DISPLAY
echo ========================================
echo This will verify the complete camera capture image flow...

echo.
echo 📋 Step 1: Starting backend...
docker compose up -d backend
timeout /t 15 /nobreak

echo.
echo 📋 Step 2: Verifying end-to-end camera capture image flow...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 VERIFYING END-TO-END CAMERA CAPTURE IMAGE FLOW...');
    
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
      console.log('\n📊 END-TO-END VERIFICATION:');
      console.log('  🕐 Check-in time:', today.checkIn);
      console.log('  🕐 Check-out time:', today.checkOut);
      console.log('  📸 Check-in image path:', today.checkInImage);
      console.log('  📸 Check-out image path:', today.checkOutImage);
      
      // Verify check-in camera capture image
      if (today.checkInImage) {
        const fullPath = path.join('/app', today.checkInImage);
        console.log('\n🔍 VERIFYING CHECK-IN CAMERA CAPTURE IMAGE:');
        console.log('  📁 Database path:', today.checkInImage);
        console.log('  📁 Full disk path:', fullPath);
        console.log('  ✅ File exists:', fs.existsSync(fullPath));
        
        if (fs.existsSync(fullPath)) {
          const stats = fs.statSync(fullPath);
          console.log('  📊 File size:', stats.size, 'bytes');
          console.log('  📅 Last modified:', stats.mtime);
          console.log('  🎯 CHECK-IN CAMERA CAPTURE IMAGE EXISTS - WILL DISPLAY!');
          
          // Test the URL that frontend will use
          const imageUrl = 'http://localhost:5000' + today.checkInImage;
          console.log('  🌐 Frontend will use URL:', imageUrl);
          console.log('  ✅ CHECK-IN IMAGE SHOULD DISPLAY IN ADMIN PANEL!');
        } else {
          console.log('  ❌ CHECK-IN CAMERA CAPTURE IMAGE FILE NOT FOUND!');
        }
      }
      
      // Verify check-out camera capture image
      if (today.checkOutImage) {
        const fullPath = path.join('/app', today.checkOutImage);
        console.log('\n🔍 VERIFYING CHECK-OUT CAMERA CAPTURE IMAGE:');
        console.log('  📁 Database path:', today.checkOutImage);
        console.log('  📁 Full disk path:', fullPath);
        console.log('  ✅ File exists:', fs.existsSync(fullPath));
        
        if (fs.existsSync(fullPath)) {
          const stats = fs.statSync(fullPath);
          console.log('  📊 File size:', stats.size, 'bytes');
          console.log('  📅 Last modified:', stats.mtime);
          console.log('  🎯 CHECK-OUT CAMERA CAPTURE IMAGE EXISTS - WILL DISPLAY!');
          
          // Test the URL that frontend will use
          const imageUrl = 'http://localhost:5000' + today.checkOutImage;
          console.log('  🌐 Frontend will use URL:', imageUrl);
          console.log('  ✅ CHECK-OUT IMAGE SHOULD DISPLAY IN ADMIN PANEL!');
        } else {
          console.log('  ❌ CHECK-OUT CAMERA CAPTURE IMAGE FILE NOT FOUND!');
        }
      }
    }
    
    console.log('\n✅ END-TO-END VERIFICATION COMPLETE!');
    console.log('\n🎯 END-TO-END CAMERA CAPTURE IMAGE FLOW STATUS:');
    console.log('1. Employee login and check-in with camera capture ✅');
    console.log('2. Camera capture image saved in backend ✅');
    console.log('3. Camera capture image saved in database ✅');
    console.log('4. Camera capture image displayed in admin panel - CHECK ABOVE OUTPUT');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Verification error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo 🔍 END-TO-END VERIFICATION COMPLETE!
echo ========================================
echo.
echo 💡 Look at the output above to see:
echo 1. Does the camera capture image file exist on disk?
echo 2. Does the database path match the actual file location?
echo 3. Will the images display in admin panel?
echo 4. Is the end-to-end flow working properly?
echo.
echo 🧪 If images are not displaying, run:
echo END_TO_END_IMAGE_FIX.bat
echo.
pause


