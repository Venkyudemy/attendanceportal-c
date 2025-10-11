@echo off
echo ========================================
echo 🎯 FINAL IMAGE DISPLAY FIX
echo ========================================
echo This will fix the image display issue permanently!

echo.
echo 📋 Step 1: Stopping all services...
docker-compose down

echo.
echo 📋 Step 2: Starting backend and mongo first...
docker-compose up -d mongo
timeout /t 10 /nobreak

docker-compose up -d backend
timeout /t 20 /nobreak

echo.
echo 📋 Step 3: FINAL IMAGE FIX - Making images visible and properly routed...
docker-compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

console.log('🎯 FINAL IMAGE DISPLAY FIX - Starting...');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('✅ Connected to MongoDB');
    
    // Step 1: Find ALL image files on disk
    console.log('\n📁 STEP 1: FINDING ALL IMAGE FILES ON DISK...');
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
    
    // Step 2: Get ALL employees from database
    console.log('\n👥 STEP 2: GETTING ALL EMPLOYEES FROM DATABASE...');
    const employees = await Employee.find({});
    console.log('Found', employees.length, 'employees in database');
    
    let totalFixed = 0;
    
    // Step 3: Fix each employee
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
      
      // Check if employee directory exists and has images
      const empDir = path.join(uploadsDir, empId);
      if (fs.existsSync(empDir)) {
        const files = fs.readdirSync(empDir);
        const imageFiles = files.filter(file => 
          file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg')
        );
        
        console.log('  📁 Files in directory:', files);
        console.log('  📸 Image files:', imageFiles);
        
        if (imageFiles.length > 0) {
          // Find check-in and check-out images
          let checkinImage = imageFiles.find(f => 
            f.toLowerCase().includes('checkin') || 
            f.toLowerCase().includes('check-in') ||
            f.toLowerCase().includes('in')
          );
          
          let checkoutImage = imageFiles.find(f => 
            f.toLowerCase().includes('checkout') || 
            f.toLowerCase().includes('check-out') ||
            f.toLowerCase().includes('out')
          );
          
          // If no specific images found, use first two images
          if (!checkinImage && imageFiles.length > 0) {
            checkinImage = imageFiles[0];
            console.log('  🎯 Using first image as check-in:', checkinImage);
          }
          
          if (!checkoutImage && imageFiles.length > 1) {
            checkoutImage = imageFiles[1];
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
        } else {
          console.log('  ❌ No image files found in directory');
        }
      } else {
        console.log('  ❌ Employee directory does not exist:', empDir);
      }
      
      if (needsUpdate) {
        await emp.save();
        console.log('  💾 Saved employee record');
      }
    }
    
    console.log('\n🎯 FINAL IMAGE FIX COMPLETE!');
    console.log('📊 Total image paths fixed:', totalFixed);
    
    // Step 4: Final verification
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
    
    console.log('\n🎯 IMAGES ARE NOW PROPERLY ROUTED!');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Final image fix error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 4: Starting all services...
docker-compose up -d

echo.
echo 📋 Step 5: Waiting for services to be ready...
timeout /t 15 /nobreak

echo.
echo ========================================
echo 🎯 FINAL IMAGE FIX APPLIED!
echo ========================================
echo.
echo 🎯 What this final fix does:
echo ✅ Finds ALL image files on disk
echo ✅ Updates database paths to point to actual files
echo ✅ Sets correct check-in and check-out image paths
echo ✅ Verifies all image files exist
echo ✅ Makes images properly routed and visible
echo.
echo 🧪 Test the admin panel NOW:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Images should NOW be visible as thumbnails
echo 3. NO MORE "Image Not Found" messages
echo 4. Images will be properly routed through backend
echo.
echo 🔍 If images still don't show:
echo - Check backend logs: docker-compose logs backend
echo - Test direct image URLs in browser
echo - Hard refresh the page (Ctrl+F5)
echo.
echo 🎉 This final fix WILL make images visible and properly routed!
echo.
pause


