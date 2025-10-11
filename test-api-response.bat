@echo off
echo ========================================
echo 🧪 TESTING API RESPONSE FOR ATTENDANCE
echo ========================================

echo.
echo 📋 Step 1: Testing backend API endpoint...
curl -k -H "Content-Type: application/json" https://localhost/api/employee/attendance

echo.
echo 📋 Step 2: Testing with authentication token...
docker-compose -f docker-compose.prod.yml exec backend node -e "
const axios = require('axios');

async function testAPI() {
  try {
    console.log('🔍 Testing /api/employee/attendance endpoint...');
    
    // Test internal API call
    const response = await axios.get('http://localhost:5000/api/employee/attendance');
    console.log('✅ API Response Status:', response.status);
    console.log('📊 Number of employees:', response.data.length);
    
    if (response.data.length > 0) {
      const firstEmployee = response.data[0];
      console.log('👤 First employee:', firstEmployee.name);
      console.log('   ID:', firstEmployee._id);
      
      if (firstEmployee.attendance && firstEmployee.attendance.today) {
        const today = firstEmployee.attendance.today;
        console.log('   📅 Today attendance:');
        console.log('     Status:', today.status || 'Not set');
        console.log('     Date:', today.date || 'Not set');
        console.log('     Check-in image:', today.checkInImage || 'None');
        console.log('     Check-out image:', today.checkOutImage || 'None');
      } else {
        console.log('   ❌ No today attendance data');
      }
    }
    
    // Check for any employee with images
    const employeesWithImages = response.data.filter(emp => {
      const today = emp.attendance?.today;
      return today && (today.checkInImage || today.checkOutImage);
    });
    
    console.log('📸 Employees with images:', employeesWithImages.length);
    
    if (employeesWithImages.length > 0) {
      employeesWithImages.forEach((emp, index) => {
        const today = emp.attendance.today;
        console.log('   Employee', index + 1, ':', emp.name);
        if (today.checkInImage) console.log('     Check-in:', today.checkInImage);
        if (today.checkOutImage) console.log('     Check-out:', today.checkOutImage);
      });
    }
    
  } catch (error) {
    console.error('❌ API Test Error:', error.message);
  }
}

testAPI();
"

echo.
echo 📋 Step 3: Checking if images actually exist on disk...
docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -name "*.jpg" -type f

echo.
echo ========================================
echo ✅ API TEST COMPLETE!
echo ========================================
echo.
pause


