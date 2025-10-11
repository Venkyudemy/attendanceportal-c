// Test script to verify calendar functionality
// This script can be run to test the calendar API endpoint

const testCalendarAPI = async () => {
  try {
    console.log('🧪 Testing Calendar API Functionality...\n');
    
    // Test API endpoint
    const API_URL = 'http://localhost:5000/api';
    const testEmployeeId = '507f1f77bcf86cd799439011'; // Replace with actual employee ID
    const currentDate = new Date();
    const month = currentDate.getMonth() + 1;
    const year = currentDate.getFullYear();
    
    console.log(`📅 Testing month: ${month}/${year}`);
    console.log(`👤 Testing employee ID: ${testEmployeeId}`);
    
    const response = await fetch(`${API_URL}/employee/${testEmployeeId}/monthly-attendance-images?month=${month}&year=${year}`, {
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const data = await response.json();
    
    console.log('\n✅ API Response Structure:');
    console.log(`- Success: ${data.success}`);
    console.log(`- Employee: ${data.employee?.name} (${data.employee?.department})`);
    console.log(`- Month: ${data.month}/${data.year}`);
    console.log(`- Calendar Data Points: ${data.calendarData?.length}`);
    console.log(`- Monthly Stats:`, data.monthlyStats);
    
    // Test calendar data structure
    if (data.calendarData && data.calendarData.length > 0) {
      console.log('\n📊 Sample Calendar Day Data:');
      const sampleDay = data.calendarData.find(day => day.hasAttendance);
      if (sampleDay) {
        console.log(`- Date: ${sampleDay.date}`);
        console.log(`- Status: ${sampleDay.status}`);
        console.log(`- Check-in: ${sampleDay.checkIn}`);
        console.log(`- Check-out: ${sampleDay.checkOut}`);
        console.log(`- Has Check-in Image: ${!!sampleDay.checkInImage}`);
        console.log(`- Has Check-out Image: ${!!sampleDay.checkOutImage}`);
        console.log(`- Hours: ${sampleDay.hours}`);
        console.log(`- Is Weekend: ${sampleDay.isWeekend}`);
      }
    }
    
    // Test 60-day retention
    console.log('\n🧹 Testing 60-Day Data Retention:');
    const allDates = data.calendarData.map(day => day.date).sort();
    const firstDate = new Date(allDates[0]);
    const lastDate = new Date(allDates[allDates.length - 1]);
    const daysDiff = Math.ceil((lastDate - firstDate) / (1000 * 60 * 60 * 24));
    
    console.log(`- Date Range: ${allDates[0]} to ${allDates[allDates.length - 1]}`);
    console.log(`- Total Days: ${daysDiff + 1}`);
    console.log(`- Within 60 days: ${daysDiff <= 60 ? '✅ Yes' : '❌ No'}`);
    
    console.log('\n🎉 Calendar API Test Completed Successfully!');
    
  } catch (error) {
    console.error('\n❌ Calendar API Test Failed:');
    console.error(`Error: ${error.message}`);
    console.error('\n🔧 Troubleshooting Tips:');
    console.error('1. Make sure the backend server is running (docker-compose up)');
    console.error('2. Check if the employee ID exists in the database');
    console.error('3. Verify the API endpoint is accessible');
    console.error('4. Check MongoDB connection');
  }
};

// Run the test if this script is executed directly
if (typeof window === 'undefined') {
  // Node.js environment
  const fetch = require('node-fetch');
  testCalendarAPI();
} else {
  // Browser environment
  console.log('Run this script in Node.js environment or call testCalendarAPI() in browser console');
}

module.exports = { testCalendarAPI };
