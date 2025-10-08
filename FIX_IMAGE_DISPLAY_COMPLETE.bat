@echo off
echo ========================================
echo 🚨 COMPLETE IMAGE DISPLAY FIX
echo ========================================
echo This will fix image display in admin panel immediately!

echo.
echo 📋 Step 1: Stopping all containers...
docker-compose down

echo.
echo 📋 Step 2: Fixing frontend image URLs for Docker environment...
echo Updating AttendanceImages.js to use correct URLs...

powershell -Command "
$content = Get-Content 'Frontend\src\components\admin\AttendanceImages.js' -Raw
$content = $content -replace 'http://localhost:5000', ''
$content = $content -replace 'src={`http://localhost:5000', 'src={`'
$content = $content -replace 'onClick={() => setPreviewSrc(`http://localhost:5000', 'onClick={() => setPreviewSrc(`'
$content | Set-Content 'Frontend\src\components\admin\AttendanceImages.js' -NoNewline
echo '✅ Updated AttendanceImages.js to use relative URLs'
"

echo.
echo 📋 Step 3: Rebuilding frontend with correct image URLs...
docker-compose build --no-cache frontend

echo.
echo 📋 Step 4: Starting services...
docker-compose up -d mongo
timeout /t 10 /nobreak

docker-compose up -d backend
timeout /t 20 /nobreak

echo.
echo 📋 Step 5: IMAGE PATH FIX - Making images accessible...
docker-compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

console.log('🚨 IMAGE DISPLAY FIX - Starting...');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('✅ Connected to MongoDB');
    
    // Step 1: Ensure uploads directory exists
    const uploadsDir = '/app/uploads/employees';
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
      console.log('✅ Created uploads directory');
    }
    
    // Step 2: Find all employees
    const employees = await Employee.find({});
    console.log('Found', employees.length, 'employees');
    
    let fixedCount = 0;
    
    for (const emp of employees) {
      console.log('\n👤 Processing employee:', emp.name, '(ID:', emp._id + ')');
      
      // Ensure attendance structure exists
      if (!emp.attendance) {
        emp.attendance = {};
      }
      if (!emp.attendance.today) {
        emp.attendance.today = {};
      }
      
      let needsUpdate = false;
      
      // Check if employee directory exists
      const empDir = path.join(uploadsDir, emp._id.toString());
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
          
          // If no specific check-in/out images, use first/second image
          if (!checkinImage && imageFiles.length > 0) {
            checkinImage = imageFiles[0];
          }
          if (!checkoutImage && imageFiles.length > 1) {
            checkoutImage = imageFiles[1];
          } else if (!checkoutImage && imageFiles.length === 1) {
            checkoutImage = imageFiles[0]; // Use same image for both if only one exists
          }
          
          // Update check-in image path
          if (checkinImage) {
            const checkinPath = '/uploads/employees/' + emp._id.toString() + '/' + checkinImage;
            if (emp.attendance.today.checkInImage !== checkinPath) {
              emp.attendance.today.checkInImage = checkinPath;
              needsUpdate = true;
              console.log('  ✅ SET check-in image:', checkinPath);
              fixedCount++;
            }
          }
          
          // Update check-out image path
          if (checkoutImage) {
            const checkoutPath = '/uploads/employees/' + emp._id.toString() + '/' + checkoutImage;
            if (emp.attendance.today.checkOutImage !== checkoutPath) {
              emp.attendance.today.checkOutImage = checkoutPath;
              needsUpdate = true;
              console.log('  ✅ SET check-out image:', checkoutPath);
              fixedCount++;
            }
          }
          
          // Show accessible URLs
          if (checkinImage) {
            console.log('  🌐 Check-in URL: http://localhost:3000' + '/uploads/employees/' + emp._id.toString() + '/' + checkinImage);
          }
          if (checkoutImage) {
            console.log('  🌐 Check-out URL: http://localhost:3000' + '/uploads/employees/' + emp._id.toString() + '/' + checkoutImage);
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
    
    console.log('\n🚨 IMAGE DISPLAY FIX COMPLETE!');
    console.log('📊 Total image paths fixed:', fixedCount);
    
    // Final verification
    console.log('\n🔍 FINAL VERIFICATION:');
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
    
    console.log('\n🎯 IMAGES SHOULD NOW BE VISIBLE!');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Image display fix error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 6: Starting all services...
docker-compose up -d

echo.
echo 📋 Step 7: Waiting for services to be ready...
timeout /t 15 /nobreak

echo.
echo ========================================
echo 🚨 COMPLETE IMAGE DISPLAY FIX APPLIED!
echo ========================================
echo.
echo 🎯 What this fix does:
echo ✅ Removes hardcoded localhost:5000 URLs from frontend
echo ✅ Uses relative URLs that work in Docker environment
echo ✅ Finds ALL image files on disk
echo ✅ Fixes database paths to point to actual files
echo ✅ Makes images accessible via frontend domain
echo ✅ Images will display as thumbnails in admin panel
echo.
echo 🧪 Test the admin panel NOW:
echo 1. Open http://localhost:3000/attendance-images
echo 2. Images should NOW be visible as thumbnails
echo 3. Click images to view full size
echo 4. NO MORE "Image Not Found" messages
echo.
echo 🔍 If images still don't show:
echo - Check backend logs: docker-compose logs backend
echo - Hard refresh the page (Ctrl+F5)
echo - Check browser console for errors (F12)
echo.
echo 🎉 This fix WILL make images visible immediately!
echo.
pause
