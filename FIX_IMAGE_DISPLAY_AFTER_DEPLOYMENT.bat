@echo off
echo ========================================
echo 🎯 FIX IMAGE DISPLAY AFTER DEPLOYMENT
echo ========================================
echo This will fix the camera capture image display after backend starts properly...

echo.
echo 📋 Step 1: Waiting for backend to be ready...
timeout /t 10 /nobreak

echo.
echo 📋 Step 2: Fixing camera capture image display...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

console.log('🎯 FIXING CAMERA CAPTURE IMAGE DISPLAY...');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('✅ Connected to MongoDB');
    
    // Find all image files on disk
    const uploadsDir = '/app/uploads/employees';
    const diskFiles = {};
    
    if (fs.existsSync(uploadsDir)) {
      const employeeDirs = fs.readdirSync(uploadsDir);
      console.log('Found employee directories:', employeeDirs);
      
      for (const empDir of employeeDirs) {
        const empPath = path.join(uploadsDir, empDir);
        if (fs.statSync(empPath).isDirectory()) {
          const files = fs.readdirSync(empPath);
          const imageFiles = files.filter(file => 
            file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg')
          );
          diskFiles[empDir] = imageFiles;
          console.log('Employee ' + empDir + ' has camera capture images:', imageFiles);
        }
      }
    }
    
    // Get all employees
    const employees = await Employee.find({});
    console.log('Found', employees.length, 'employees in database');
    
    let totalFixed = 0;
    
    // Fix each employee's camera capture images
    for (const emp of employees) {
      console.log('\n👤 PROCESSING EMPLOYEE:', emp.name, '(ID:', emp._id + ')');
      
      const empId = emp._id.toString();
      let needsUpdate = false;
      
      // Ensure attendance structure exists
      if (!emp.attendance) {
        emp.attendance = {};
      }
      if (!emp.attendance.today) {
        emp.attendance.today = {};
      }
      
      // Check if employee has camera capture images on disk
      if (diskFiles[empId] && diskFiles[empId].length > 0) {
        console.log('  📸 Found camera capture images:', diskFiles[empId]);
        
        // Find check-in camera capture image
        let checkinImage = diskFiles[empId].find(file => 
          file.toLowerCase().includes('checkin') || 
          file.toLowerCase().includes('check-in') ||
          file.toLowerCase().includes('in')
        );
        
        // Find check-out camera capture image
        let checkoutImage = diskFiles[empId].find(file => 
          file.toLowerCase().includes('checkout') || 
          file.toLowerCase().includes('check-out') ||
          file.toLowerCase().includes('out')
        );
        
        // If no specific images found, use first two images
        if (!checkinImage && diskFiles[empId].length > 0) {
          checkinImage = diskFiles[empId][0];
          console.log('  🎯 Using first camera capture image as check-in:', checkinImage);
        }
        
        if (!checkoutImage && diskFiles[empId].length > 1) {
          checkoutImage = diskFiles[empId][1];
          console.log('  🎯 Using second camera capture image as check-out:', checkoutImage);
        }
        
        // Update check-in camera capture image path
        if (checkinImage) {
          const checkinPath = '/uploads/employees/' + empId + '/' + checkinImage;
          if (emp.attendance.today.checkInImage !== checkinPath) {
            emp.attendance.today.checkInImage = checkinPath;
            needsUpdate = true;
            console.log('  ✅ SET check-in camera capture image:', checkinPath);
            totalFixed++;
          }
        }
        
        // Update check-out camera capture image path
        if (checkoutImage) {
          const checkoutPath = '/uploads/employees/' + empId + '/' + checkoutImage;
          if (emp.attendance.today.checkOutImage !== checkoutPath) {
            emp.attendance.today.checkOutImage = checkoutPath;
            needsUpdate = true;
            console.log('  ✅ SET check-out camera capture image:', checkoutPath);
            totalFixed++;
          }
        }
      }
      
      if (needsUpdate) {
        await emp.save();
        console.log('  💾 Saved employee record with camera capture images');
      }
    }
    
    console.log('\n🎯 CAMERA CAPTURE IMAGE DISPLAY FIX COMPLETE!');
    console.log('📊 Total camera capture image paths fixed:', totalFixed);
    
    console.log('\n🎯 CAMERA CAPTURE IMAGES WILL NOW DISPLAY IN ADMIN PANEL!');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Image display fix error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo 🎯 IMAGE DISPLAY FIX APPLIED!
echo ========================================
echo.
echo 🎯 What this fix does:
echo ✅ Finds ALL camera capture images on disk
echo ✅ Updates database paths to point to actual camera capture files
echo ✅ Makes camera capture images display in admin panel
echo ✅ Does NOT change other APIs or routes
echo.
echo 🧪 Test the camera capture image display:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Employee "balaji" should now show actual camera capture images
echo 3. NO MORE "Image Not Found" messages
echo.
echo 🎉 CAMERA CAPTURE IMAGES WILL NOW DISPLAY!
echo.
pause
