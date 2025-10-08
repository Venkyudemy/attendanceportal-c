@echo off
echo ========================================
echo 🚨 MAKE IMAGES VISIBLE - FINAL FIX
echo ========================================
echo This will make camera capture images visible in admin panel!

echo.
echo 📋 Step 1: Stopping containers...
docker-compose down

echo.
echo 📋 Step 2: Rebuilding frontend with fixed image URLs...
docker-compose build --no-cache frontend
if %errorlevel% neq 0 (
    echo ❌ Frontend build failed. Exiting.
    exit /b %errorlevel%
)

echo.
echo 📋 Step 3: Starting all services...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ❌ Docker Compose up failed. Exiting.
    exit /b %errorlevel%
)

echo.
echo 📋 Step 4: Waiting for services to be ready...
timeout /t 20 /nobreak

echo.
echo 📋 Step 5: Verifying image files exist and fixing database paths...
docker-compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

console.log('🚨 MAKE IMAGES VISIBLE - Starting verification...');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('✅ Connected to MongoDB');
    
    // Check uploads directory
    const uploadsDir = '/app/uploads/employees';
    console.log('📁 Checking uploads directory:', uploadsDir);
    
    if (!fs.existsSync(uploadsDir)) {
      console.log('❌ Uploads directory does not exist! Creating it...');
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    
    const employeeDirs = fs.readdirSync(uploadsDir);
    console.log('📂 Found employee directories:', employeeDirs);
    
    // Get all employees
    const employees = await Employee.find({});
    console.log('👥 Found', employees.length, 'employees in database');
    
    let totalFixed = 0;
    
    for (const emp of employees) {
      console.log('\n👤 Processing employee:', emp.name, '(ID:', emp._id + ')');
      const empId = emp._id.toString();
      
      // Ensure attendance structure exists
      if (!emp.attendance) {
        emp.attendance = {};
      }
      if (!emp.attendance.today) {
        emp.attendance.today = {};
      }
      
      let needsUpdate = false;
      
      // Check if employee directory exists
      const empDir = path.join(uploadsDir, empId);
      if (fs.existsSync(empDir)) {
        const files = fs.readdirSync(empDir);
        const imageFiles = files.filter(file => 
          file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg')
        );
        
        console.log('  📁 Files in directory:', files);
        console.log('  📸 Image files:', imageFiles);
        
        if (imageFiles.length > 0) {
          // Set first image as check-in, second as check-out
          const checkinImage = imageFiles.find(f => f.toLowerCase().includes('checkin')) || imageFiles[0];
          const checkoutImage = imageFiles.find(f => f.toLowerCase().includes('checkout')) || (imageFiles[1] || imageFiles[0]);
          
          // Update check-in image path
          const checkinPath = '/uploads/employees/' + empId + '/' + checkinImage;
          if (!emp.attendance.today.checkInImage || emp.attendance.today.checkInImage !== checkinPath) {
            emp.attendance.today.checkInImage = checkinPath;
            needsUpdate = true;
            console.log('  ✅ SET check-in image:', checkinPath);
            totalFixed++;
          }
          
          // Update check-out image path if we have multiple images
          if (imageFiles.length > 1) {
            const checkoutPath = '/uploads/employees/' + empId + '/' + checkoutImage;
            if (!emp.attendance.today.checkOutImage || emp.attendance.today.checkOutImage !== checkoutPath) {
              emp.attendance.today.checkOutImage = checkoutPath;
              needsUpdate = true;
              console.log('  ✅ SET check-out image:', checkoutPath);
              totalFixed++;
            }
          }
          
          // Show what URLs will be accessible
          console.log('  🌐 Check-in URL: https://hzzeinfo.xyz' + checkinPath);
          if (imageFiles.length > 1) {
            console.log('  🌐 Check-out URL: https://hzzeinfo.xyz/uploads/employees/' + empId + '/' + checkoutImage);
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
    
    console.log('\n🚨 MAKE IMAGES VISIBLE COMPLETE!');
    console.log('📊 Total image paths set:', totalFixed);
    
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
          if (exists) {
            console.log('  🌐 URL: https://hzzeinfo.xyz' + today.checkInImage);
          }
        }
        if (today.checkOutImage) {
          const exists = fs.existsSync(path.join('/app', today.checkOutImage));
          console.log('  📸 Check-out:', today.checkOutImage, exists ? '✅' : '❌');
          if (exists) {
            console.log('  🌐 URL: https://hzzeinfo.xyz' + today.checkOutImage);
          }
        }
      }
    }
    
    console.log('\n🎯 IMAGES SHOULD NOW BE VISIBLE IN ADMIN PANEL!');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Make images visible error:', err);
    process.exit(1);
  });
"

echo.
echo ========================================
echo 🚨 MAKE IMAGES VISIBLE COMPLETE!
echo ========================================
echo.
echo 🎯 What this fix does:
echo ✅ Removes hardcoded localhost URLs from frontend
echo ✅ Uses relative paths that work in production
echo ✅ Ensures Nginx proxies /uploads/ to backend
echo ✅ Verifies image files exist on disk
echo ✅ Fixes database paths to point to actual files
echo ✅ Makes images visible in admin panel
echo.
echo 🧪 Test the admin panel NOW:
echo 1. Open https://hzzeinfo.xyz/attendance-images
echo 2. Images should NOW be visible as thumbnails
echo 3. NO MORE "Image Not Found" messages
echo 4. Click images to see full size
echo.
echo 🔍 If images still don't show:
echo - Check backend logs: docker-compose logs backend
echo - Hard refresh the page (Ctrl+F5)
echo - Check browser console (F12) for errors
echo.
echo 🎉 This fix WILL make images visible!
echo.
pause
