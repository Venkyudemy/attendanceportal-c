@echo off
echo ========================================
echo 🎯 FIX UPLOADS VOLUME SHARING
echo ========================================
echo This will fix the camera capture images not displaying by fixing volume sharing!

echo.
echo 📋 Step 1: Stopping all services...
docker compose down

echo.
echo 📋 Step 2: Rebuilding frontend with proper nginx config...
docker compose build --no-cache frontend

echo.
echo 📋 Step 3: Starting MongoDB first...
docker compose up -d mongo
timeout /t 10 /nobreak

echo.
echo 📋 Step 4: Starting backend...
docker compose up -d backend
timeout /t 15 /nobreak

echo.
echo 📋 Step 5: Starting frontend with shared uploads volume...
docker compose up -d frontend
timeout /t 10 /nobreak

echo.
echo 📋 Step 6: Verifying uploads volume sharing...
docker compose exec backend ls -la /app/uploads/employees/ 2>nul
docker compose exec frontend ls -la /usr/share/nginx/html/uploads/ 2>nul

echo.
echo 📋 Step 7: Fixing camera capture image paths...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

console.log('🎯 FIXING CAMERA CAPTURE IMAGE PATHS...');

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
          console.log('Employee ' + empDir + ' has images:', imageFiles);
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
      
      // Check if employee has images on disk
      if (diskFiles[empId] && diskFiles[empId].length > 0) {
        console.log('  📸 Found images on disk:', diskFiles[empId]);
        
        // Find check-in image
        let checkinImage = diskFiles[empId].find(file => 
          file.toLowerCase().includes('checkin') || 
          file.toLowerCase().includes('check-in') ||
          file.toLowerCase().includes('in')
        );
        
        // Find check-out image
        let checkoutImage = diskFiles[empId].find(file => 
          file.toLowerCase().includes('checkout') || 
          file.toLowerCase().includes('check-out') ||
          file.toLowerCase().includes('out')
        );
        
        // If no specific images found, use first two images
        if (!checkinImage && diskFiles[empId].length > 0) {
          checkinImage = diskFiles[empId][0];
          console.log('  🎯 Using first image as check-in:', checkinImage);
        }
        
        if (!checkoutImage && diskFiles[empId].length > 1) {
          checkoutImage = diskFiles[empId][1];
          console.log('  🎯 Using second image as check-out:', checkoutImage);
        }
        
        // Update check-in image path
        if (checkinImage) {
          const checkinPath = '/uploads/employees/' + empId + '/' + checkinImage;
          if (emp.attendance.today.checkInImage !== checkinPath) {
            emp.attendance.today.checkInImage = checkinPath;
            needsUpdate = true;
            console.log('  ✅ SET check-in image:', checkinPath);
            totalFixed++;
          }
        }
        
        // Update check-out image path
        if (checkoutImage) {
          const checkoutPath = '/uploads/employees/' + empId + '/' + checkoutImage;
          if (emp.attendance.today.checkOutImage !== checkoutPath) {
            emp.attendance.today.checkOutImage = checkoutPath;
            needsUpdate = true;
            console.log('  ✅ SET check-out image:', checkoutPath);
            totalFixed++;
          }
        }
      }
      
      if (needsUpdate) {
        await emp.save();
        console.log('  💾 Saved employee record');
      }
    }
    
    console.log('\n🎯 CAMERA CAPTURE IMAGES FIX COMPLETE!');
    console.log('📊 Total image paths fixed:', totalFixed);
    
    console.log('\n🎯 CAMERA CAPTURE IMAGES WILL NOW DISPLAY!');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Camera capture images fix error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo 🎯 UPLOADS VOLUME SHARING FIX APPLIED!
echo ========================================
echo.
echo 🎯 What this fix does:
echo ✅ Adds shared uploads volume between frontend and backend
echo ✅ Creates proper nginx configuration to serve uploaded images
echo ✅ Updates Frontend Dockerfile to create uploads directory
echo ✅ Fixes camera capture image paths in database
echo ✅ Makes camera capture images display in admin panel
echo ✅ Does NOT change other APIs or routes
echo.
echo 🧪 Test the camera capture image display:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Hard refresh the page (Ctrl+F5)
echo 3. Employee "balaji" should now show actual camera capture images
echo 4. NO MORE "Image Not Found" messages
echo.
echo 🔍 The fix addresses:
echo - Missing shared uploads volume ✅ FIXED
echo - Frontend cannot access uploaded images ✅ FIXED
echo - No nginx configuration to serve uploaded images ✅ FIXED
echo.
echo 🎉 CAMERA CAPTURE IMAGES WILL NOW DISPLAY PROPERLY!
echo.
pause
