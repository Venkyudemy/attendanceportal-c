@echo off
echo ========================================
echo 🖼️ TESTING IMAGE ACCESS & DISPLAY
echo ========================================

echo.
echo 📋 Step 1: Checking what images exist on disk...
docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -type f -name "*.jpg" -exec ls -la {} \;

echo.
echo 📋 Step 2: Checking employee database for image paths...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    console.log('🔍 Checking employee image paths...');
    
    const employees = await Employee.find({});
    
    employees.forEach((emp, index) => {
      const today = emp.attendance?.today;
      if (today && (today.checkInImage || today.checkOutImage)) {
        console.log('\n👤 Employee:', emp.name);
        console.log('   ID:', emp._id);
        
        if (today.checkInImage) {
          console.log('   📸 Check-in image path:', today.checkInImage);
          console.log('   🔗 Full URL: https://hzzeinfo.xyz' + today.checkInImage);
        }
        
        if (today.checkOutImage) {
          console.log('   📸 Check-out image path:', today.checkOutImage);
          console.log('   🔗 Full URL: https://hzzeinfo.xyz' + today.checkOutImage);
        }
      }
    });
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database error:', err);
    process.exit(1);
  });
"

echo.
echo 📋 Step 3: Testing image accessibility via Nginx...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const axios = require('axios');

async function testImageURLs() {
  try {
    const mongoose = require('mongoose');
    const Employee = require('./models/Employee');
    
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongo:27017/attendanceportal');
    const employees = await Employee.find({});
    
    for (const emp of employees) {
      const today = emp.attendance?.today;
      if (today && (today.checkInImage || today.checkOutImage)) {
        console.log('\n🧪 Testing image URLs for:', emp.name);
        
        if (today.checkInImage) {
          try {
            const checkInUrl = 'https://hzzeinfo.xyz' + today.checkInImage;
            console.log('   Testing check-in URL:', checkInUrl);
            const response = await axios.head(checkInUrl, { timeout: 5000 });
            console.log('   ✅ Check-in image accessible:', response.status);
          } catch (error) {
            console.log('   ❌ Check-in image not accessible:', error.message);
          }
        }
        
        if (today.checkOutImage) {
          try {
            const checkOutUrl = 'https://hzzeinfo.xyz' + today.checkOutImage;
            console.log('   Testing check-out URL:', checkOutUrl);
            const response = await axios.head(checkOutUrl, { timeout: 5000 });
            console.log('   ✅ Check-out image accessible:', response.status);
          } catch (error) {
            console.log('   ❌ Check-out image not accessible:', error.message);
          }
        }
      }
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Test error:', error);
    process.exit(1);
  }
}

testImageURLs();
"

echo.
echo 📋 Step 4: Checking Nginx uploads proxy configuration...
docker-compose -f docker-compose.prod.yml exec frontend cat /etc/nginx/conf.d/default.conf | grep -A 5 "location /uploads"

echo.
echo ========================================
echo ✅ IMAGE ACCESS TEST COMPLETE!
echo ========================================
echo.
echo 🎯 This will show:
echo - What image files exist on disk
echo - Database paths for images
echo - Whether images are accessible via URLs
echo - Nginx proxy configuration
echo.
pause
