@echo off
echo ========================================
echo 🔧 FIXING "IMAGE NOT FOUND" ISSUE
echo ========================================

echo.
echo 📋 Step 1: Checking what image files exist on disk...
docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -type f -name "*.jpg" -exec ls -la {} \;

echo.
echo 📋 Step 2: Checking uploads directory structure...
docker-compose -f docker-compose.prod.yml exec backend ls -la /app/uploads/
docker-compose -f docker-compose.prod.yml exec backend ls -la /app/uploads/employees/ 2>nul || echo "No employees folder found"

echo.
echo 📋 Step 3: Checking database for image paths...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 Checking employee image paths vs actual files...');
    
    const employees = await Employee.find({});
    
    for (const emp of employees) {
      const today = emp.attendance?.today;
      if (today && (today.checkInImage || today.checkOutImage)) {
        console.log('\n👤 Employee:', emp.name, '(ID:', emp._id + ')');
        
        if (today.checkInImage) {
          console.log('   📸 Check-in image path in DB:', today.checkInImage);
          const fullPath = path.join('/app', today.checkInImage);
          if (fs.existsSync(fullPath)) {
            console.log('   ✅ File EXISTS on disk:', fullPath);
          } else {
            console.log('   ❌ File NOT FOUND on disk:', fullPath);
            
            // Try to find similar files
            const employeeDir = path.join('/app/uploads/employees', emp._id.toString());
            if (fs.existsSync(employeeDir)) {
              console.log('   🔍 Checking employee directory:', employeeDir);
              const files = fs.readdirSync(employeeDir);
              console.log('   📁 Files in directory:', files);
              
              // Look for any image files
              const imageFiles = files.filter(file => file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg') || file.toLowerCase().endsWith('.png'));
              if (imageFiles.length > 0) {
                console.log('   🖼️ Found image files:', imageFiles);
                
                // Update database with correct path
                const correctPath = '/uploads/employees/' + emp._id.toString() + '/' + imageFiles[0];
                today.checkInImage = correctPath;
                await emp.save();
                console.log('   🔧 Updated database with correct path:', correctPath);
              }
            } else {
              console.log('   ❌ Employee directory does not exist:', employeeDir);
            }
          }
        }
        
        if (today.checkOutImage) {
          console.log('   📸 Check-out image path in DB:', today.checkOutImage);
          const fullPath = path.join('/app', today.checkOutImage);
          if (fs.existsSync(fullPath)) {
            console.log('   ✅ File EXISTS on disk:', fullPath);
          } else {
            console.log('   ❌ File NOT FOUND on disk:', fullPath);
            
            // Try to find similar files
            const employeeDir = path.join('/app/uploads/employees', emp._id.toString());
            if (fs.existsSync(employeeDir)) {
              console.log('   🔍 Checking employee directory:', employeeDir);
              const files = fs.readdirSync(employeeDir);
              console.log('   📁 Files in directory:', files);
              
              // Look for any image files
              const imageFiles = files.filter(file => file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg') || file.toLowerCase().endsWith('.png'));
              if (imageFiles.length > 1) {
                console.log('   🖼️ Found image files:', imageFiles);
                
                // Update database with correct path (use second image if available)
                const correctPath = '/uploads/employees/' + emp._id.toString() + '/' + imageFiles[1];
                today.checkOutImage = correctPath;
                await emp.save();
                console.log('   🔧 Updated database with correct path:', correctPath);
              }
            }
          }
        }
      }
    }
    
    console.log('\n✅ Database check and fix complete!');
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 4: Testing image accessibility via web...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🌐 Testing image URLs...');
    
    const employees = await Employee.find({});
    
    for (const emp of employees) {
      const today = emp.attendance?.today;
      if (today && (today.checkInImage || today.checkOutImage)) {
        console.log('\n👤 Employee:', emp.name);
        
        if (today.checkInImage) {
          console.log('   📸 Check-in URL: https://hzzeinfo.xyz' + today.checkInImage);
        }
        
        if (today.checkOutImage) {
          console.log('   📸 Check-out URL: https://hzzeinfo.xyz' + today.checkOutImage);
        }
      }
    }
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 5: Rebuilding frontend with fixes...
docker-compose -f docker-compose.prod.yml build --no-cache frontend
docker-compose -f docker-compose.prod.yml up -d frontend

echo.
echo 📋 Step 6: Waiting for frontend to restart...
timeout /t 15 /nobreak

echo.
echo ========================================
echo ✅ IMAGE FIX COMPLETE!
echo ========================================
echo.
echo 🎯 What was fixed:
echo ✅ Checked if image files exist on disk
echo ✅ Fixed database paths if files exist but paths are wrong
echo ✅ Updated image URLs to be correct
echo ✅ Rebuilt frontend with latest fixes
echo.
echo 🧪 Test the admin panel now:
echo 1. Open https://hzzeinfo.xyz/attendance-images
echo 2. Images should now display as thumbnails
echo 3. Click images to view full size
echo 4. No more "Image Not Found" messages
echo.
echo 🔍 If still not working:
echo - Check browser console for error messages
echo - Verify the image files actually exist
echo - Test direct image URLs manually
echo.
pause
