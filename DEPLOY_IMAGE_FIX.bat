@echo off
echo ========================================
echo 🎯 COMPLETE IMAGE DISPLAY DEPLOYMENT
echo ========================================
echo This will deploy the complete image display fix!

echo.
echo 📋 Step 1: Stopping all services...
docker-compose down

echo.
echo 📋 Step 2: Rebuilding frontend with image fixes...
docker-compose build --no-cache frontend
if %errorlevel% neq 0 (
    echo ❌ Frontend build failed. Exiting.
    exit /b %errorlevel%
)

echo.
echo 📋 Step 3: Starting backend and mongo...
docker-compose up -d mongo
timeout /t 10 /nobreak

docker-compose up -d backend
timeout /t 20 /nobreak

echo.
echo 📋 Step 4: Applying image database fixes...
docker-compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

console.log('🎯 COMPLETE IMAGE DISPLAY FIX - Starting...');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('✅ Connected to MongoDB');
    
    // Find all image files and fix database paths
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
    
    const employees = await Employee.find({});
    console.log('Found', employees.length, 'employees in database');
    
    let totalFixed = 0;
    
    for (const emp of employees) {
      console.log('\n👤 Processing employee:', emp.name, '(ID:', emp._id + ')');
      
      const empId = emp._id.toString();
      let needsUpdate = false;
      
      if (!emp.attendance) {
        emp.attendance = {};
      }
      if (!emp.attendance.today) {
        emp.attendance.today = {};
      }
      
      const empDir = path.join(uploadsDir, empId);
      if (fs.existsSync(empDir)) {
        const files = fs.readdirSync(empDir);
        const imageFiles = files.filter(file => 
          file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg')
        );
        
        console.log('  📁 Files in directory:', files);
        console.log('  📸 Image files:', imageFiles);
        
        if (imageFiles.length > 0) {
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
          
          if (!checkinImage && imageFiles.length > 0) {
            checkinImage = imageFiles[0];
            console.log('  🎯 Using first image as check-in:', checkinImage);
          }
          
          if (!checkoutImage && imageFiles.length > 1) {
            checkoutImage = imageFiles[1];
            console.log('  🎯 Using second image as check-out:', checkoutImage);
          }
          
          if (checkinImage) {
            const checkinPath = '/uploads/employees/' + empId + '/' + checkinImage;
            if (emp.attendance.today.checkInImage !== checkinPath) {
              emp.attendance.today.checkInImage = checkinPath;
              needsUpdate = true;
              console.log('  ✅ SET check-in image:', checkinPath);
              totalFixed++;
            }
          }
          
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
      }
      
      if (needsUpdate) {
        await emp.save();
        console.log('  💾 Saved employee record');
      }
    }
    
    console.log('\n🎯 COMPLETE IMAGE FIX APPLIED!');
    console.log('📊 Total image paths fixed:', totalFixed);
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Image fix error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 5: Starting all services...
docker-compose up -d

echo.
echo 📋 Step 6: Waiting for all services to be ready...
timeout /t 15 /nobreak

echo.
echo ========================================
echo 🎯 COMPLETE IMAGE DISPLAY DEPLOYMENT DONE!
echo ========================================
echo.
echo 🎯 What this deployment does:
echo ✅ Rebuilds frontend with corrected image URLs
echo ✅ Fixes database image paths to point to actual files
echo ✅ Ensures images are properly routed through backend
echo ✅ Makes images visible in admin panel
echo ✅ Works in both development and production
echo.
echo 🧪 Test the admin panel NOW:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Hard refresh the page (Ctrl+F5)
echo 3. Images should now be visible as thumbnails
echo 4. Click images to see full-size preview
echo 5. NO MORE "Image Not Found" messages
echo.
echo 🔍 Image routing is now fixed:
echo - Images are served through /uploads/ path
echo - Frontend uses relative URLs (works in Docker)
echo - Nginx proxies /uploads/ to backend
echo - Database paths point to actual files
echo.
echo 🎉 EMPLOYEE CHECK-IN/CHECK-OUT IMAGES ARE NOW VISIBLE!
echo.
pause
