@echo off
echo ========================================
echo 🔍 TESTING IMAGE SERVING
echo ========================================
echo This will test if images are being served correctly...

echo.
echo 📋 Step 1: Checking if backend is serving images...
curl -I http://localhost:5000/uploads/ 2>nul || echo "Backend not responding"

echo.
echo 📋 Step 2: Testing specific image URL...
docker compose exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 TESTING IMAGE SERVING...');
    
    const emp = await Employee.findOne({ name: 'balaji' });
    if (!emp) {
      console.log('❌ Employee balaji not found');
      process.exit(1);
    }
    
    console.log('👤 Found employee:', emp.name);
    
    if (emp.attendance?.today) {
      const today = emp.attendance.today;
      console.log('\n📊 Image paths in database:');
      console.log('  📸 Check-in image path:', today.checkInImage || 'NULL');
      console.log('  📸 Check-out image path:', today.checkOutImage || 'NULL');
      
      if (today.checkInImage) {
        const testUrl = 'http://localhost:5000' + today.checkInImage;
        console.log('\n🌐 Test URLs for frontend:');
        console.log('  📸 Check-in URL:', testUrl);
        console.log('  💡 Frontend should use:', today.checkInImage);
        console.log('  💡 Full URL would be:', testUrl);
      }
      
      if (today.checkOutImage) {
        const testUrl = 'http://localhost:5000' + today.checkOutImage;
        console.log('  📸 Check-out URL:', testUrl);
        console.log('  💡 Frontend should use:', today.checkOutImage);
        console.log('  💡 Full URL would be:', testUrl);
      }
    }
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Test error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 3: Testing if images are accessible via HTTP...
docker compose exec backend node -e "
const http = require('http');
const fs = require('fs');
const path = require('path');

console.log('🔍 TESTING IMAGE ACCESSIBILITY...');

// Test if we can access images via HTTP
const testImageAccess = (imagePath) => {
  const fullPath = path.join('/app', imagePath);
  console.log('  📁 Testing path:', fullPath);
  console.log('  ✅ File exists:', fs.existsSync(fullPath));
  
  if (fs.existsSync(fullPath)) {
    const stats = fs.statSync(fullPath);
    console.log('  📊 File size:', stats.size, 'bytes');
    console.log('  📅 Last modified:', stats.mtime);
    console.log('  🎯 IMAGE FILE EXISTS - SHOULD BE ACCESSIBLE!');
  } else {
    console.log('  ❌ IMAGE FILE NOT FOUND - WILL NOT BE ACCESSIBLE!');
  }
};

// Test balaji's images
testImageAccess('/uploads/employees/68e4bfe05183cffc04319bf8/checkin_2025-10-09_16-36-00.jpg');
"

echo.
echo ========================================
echo 🔍 IMAGE SERVING TEST COMPLETE!
echo ========================================
echo.
echo 💡 Look at the output above to see:
echo 1. Is the backend serving images correctly?
echo 2. Are the image URLs correct?
echo 3. Do the image files exist on disk?
echo 4. Are the paths accessible?
echo.
pause
