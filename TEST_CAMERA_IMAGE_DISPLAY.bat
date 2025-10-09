@echo off
echo ========================================
echo 🔍 TESTING CAMERA IMAGE DISPLAY
echo ========================================
echo Testing if camera capture images will display in admin panel...

echo.
echo 📋 Step 1: Starting backend...
docker compose up -d backend
timeout /t 15 /nobreak

echo.
echo 📋 Step 2: Testing camera capture images for employee balaji...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 TESTING CAMERA IMAGE DISPLAY FOR BALAJI...');
    
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
      
      // Check if check-in camera capture image will display
      if (today.checkInImage) {
        const fullPath = path.join('/app', today.checkInImage);
        console.log('\n🔍 TESTING CHECK-IN CAMERA CAPTURE IMAGE:');
        console.log('  📁 Database path:', today.checkInImage);
        console.log('  📁 Full disk path:', fullPath);
        console.log('  ✅ File exists:', fs.existsSync(fullPath));
        
        if (fs.existsSync(fullPath)) {
          const stats = fs.statSync(fullPath);
          console.log('  📊 File size:', stats.size, 'bytes');
          console.log('  📅 Last modified:', stats.mtime);
          console.log('  🎯 CAMERA CAPTURE IMAGE EXISTS - WILL DISPLAY IN ADMIN PANEL!');
          
          // Test the URL that frontend will use
          const imageUrl = 'http://localhost:5000' + today.checkInImage;
          console.log('  🌐 Frontend will use URL:', imageUrl);
          console.log('  ✅ IMAGE SHOULD DISPLAY IN ADMIN PANEL!');
        } else {
          console.log('  ❌ CAMERA CAPTURE IMAGE FILE NOT FOUND - WILL NOT DISPLAY!');
          
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
            console.log('  📸 Camera capture image files:', imageFiles);
            
            if (imageFiles.length > 0) {
              console.log('  🎯 FOUND CAMERA CAPTURE IMAGES - NEED TO UPDATE DATABASE PATH!');
              console.log('  💡 Correct path should be: /uploads/employees/' + empId + '/' + imageFiles[0]);
              console.log('  🔧 Run FINAL_CAMERA_IMAGE_DISPLAY_FIX.bat to fix this!');
            } else {
              console.log('  ❌ NO CAMERA CAPTURE IMAGES FOUND - IMAGES NOT SAVED PROPERLY');
            }
          } else {
            console.log('  ❌ EMPLOYEE DIRECTORY DOES NOT EXIST');
          }
        }
      } else {
        console.log('  ❌ NO CHECK-IN IMAGE PATH IN DATABASE');
      }
    }
    
    console.log('\n✅ CAMERA IMAGE DISPLAY TEST COMPLETE!');
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Test error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo 🔍 CAMERA IMAGE DISPLAY TEST COMPLETE!
echo ========================================
echo.
echo 💡 Look at the output above to see:
echo 1. Does the camera capture image file exist on disk?
echo 2. Does the database path match the actual file location?
echo 3. Will the image display in admin panel?
echo 4. If not, run FINAL_CAMERA_IMAGE_DISPLAY_FIX.bat to fix it!
echo.
pause
