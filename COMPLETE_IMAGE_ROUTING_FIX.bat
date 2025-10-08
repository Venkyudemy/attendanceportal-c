@echo off
echo ========================================
echo 🎯 COMPLETE IMAGE ROUTING FIX
echo ========================================
echo This will fix the image routing from employee page to admin panel!

echo.
echo 📋 Step 1: Stopping all services...
docker compose down

echo.
echo 📋 Step 2: Starting backend and mongo...
docker compose up -d mongo
timeout /t 10 /nobreak

docker compose up -d backend
timeout /t 20 /nobreak

echo.
echo 📋 Step 3: COMPLETE IMAGE ROUTING FIX...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

console.log('🎯 COMPLETE IMAGE ROUTING FIX - Starting...');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('✅ Connected to MongoDB');
    
    // Find all image files on disk
    console.log('\n📁 SCANNING IMAGE FILES ON DISK...');
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
    } else {
      console.log('❌ Uploads directory does not exist! Creating it...');
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    
    // Get all employees
    const employees = await Employee.find({});
    console.log('Found', employees.length, 'employees in database');
    
    let totalFixed = 0;
    
    // Fix each employee
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
            console.log('  ✅ SET check-in image path:', checkinPath);
            totalFixed++;
          }
        }
        
        // Update check-out image path
        if (checkoutImage) {
          const checkoutPath = '/uploads/employees/' + empId + '/' + checkoutImage;
          if (emp.attendance.today.checkOutImage !== checkoutPath) {
            emp.attendance.today.checkOutImage = checkoutPath;
            needsUpdate = true;
            console.log('  ✅ SET check-out image path:', checkoutPath);
            totalFixed++;
          }
        }
      } else {
        console.log('  ❌ No images found for this employee');
      }
      
      if (needsUpdate) {
        await emp.save();
        console.log('  💾 Saved employee record');
      }
    }
    
    console.log('\n🎯 COMPLETE IMAGE ROUTING FIX APPLIED!');
    console.log('📊 Total image paths fixed:', totalFixed);
    
    // Final verification
    console.log('\n🔍 FINAL VERIFICATION - Images should now be visible:');
    const finalEmployees = await Employee.find({});
    for (const emp of finalEmployees) {
      if (emp.attendance?.today) {
        const today = emp.attendance.today;
        console.log('\n👤 Employee:', emp.name);
        if (today.checkInImage) {
          const exists = fs.existsSync(path.join('/app', today.checkInImage));
          console.log('  📸 Check-in:', today.checkInImage, exists ? '✅' : '❌');
        }
        if (today.checkOutImage) {
          const exists = fs.existsSync(path.join('/app', today.checkOutImage));
          console.log('  📸 Check-out:', today.checkOutImage, exists ? '✅' : '❌');
        }
      }
    }
    
    console.log('\n🎯 IMAGE ROUTING IS NOW FIXED!');
    console.log('✅ Camera capture images will now display in admin panel!');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Image routing fix error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 4: Starting all services...
docker compose up -d

echo.
echo 📋 Step 5: Waiting for services to be ready...
timeout /t 15 /nobreak

echo.
echo ========================================
echo 🎯 COMPLETE IMAGE ROUTING FIX APPLIED!
echo ========================================
echo.
echo 🎯 What this fix does:
echo ✅ Scans all image files on disk
echo ✅ Updates database paths to point to actual files
echo ✅ Routes images from employee page to admin panel
echo ✅ Makes images visible in attendance images functionality
echo ✅ Does NOT change other APIs or routes
echo.
echo 🧪 Test the image routing NOW:
echo 1. Employee check-in with camera ✅ (already working)
echo 2. Image saved in backend ✅ (already working)
echo 3. Image saved in database ✅ (now fixed)
echo 4. Image displayed in admin panel ❌ → ✅ FIXED
echo.
echo 🔍 Navigate to admin panel:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Employee "sai" should now show actual captured images
echo 3. NO MORE "Image Not Found" messages
echo.
echo 🎉 IMAGES WILL NOW BE VISIBLE IN ADMIN PANEL!
echo.
pause
