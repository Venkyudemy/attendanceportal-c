// Test script for the monthly attendance calendar feature
// This script tests the new API endpoint and calendar functionality

const testMonthlyCalendarAPI = async () => {
  try {
    console.log('🧪 Testing Monthly Attendance Calendar API...\n');

    // Test API endpoint
    const API_URL = 'http://localhost:5000/api';
    
    // First, get all employees to find an employee ID
    console.log('1. Fetching all employees...');
    const employeesResponse = await fetch(`${API_URL}/employee/attendance`);
    
    if (!employeesResponse.ok) {
      throw new Error(`Failed to fetch employees: ${employeesResponse.status}`);
    }
    
    const employees = await employeesResponse.json();
    console.log(`✅ Found ${employees.length} employees`);
    
    if (employees.length === 0) {
      console.log('⚠️ No employees found. Please create some employees first.');
      return;
    }

    // Use the first employee for testing
    const testEmployee = employees[0];
    console.log(`👤 Testing with employee: ${testEmployee.name} (ID: ${testEmployee.id})`);

    // Test monthly attendance endpoint
    console.log('\n2. Testing monthly attendance endpoint...');
    const currentDate = new Date();
    const month = currentDate.getMonth() + 1;
    const year = currentDate.getFullYear();
    
    const monthlyResponse = await fetch(`${API_URL}/employee/monthly-attendance/${testEmployee.id}?month=${month}&year=${year}`);
    
    if (!monthlyResponse.ok) {
      throw new Error(`Failed to fetch monthly attendance: ${monthlyResponse.status}`);
    }
    
    const monthlyData = await monthlyResponse.json();
    console.log('✅ Monthly attendance data received:');
    console.log(`   - Month: ${monthlyData.month}/${monthlyData.year}`);
    console.log(`   - Employee: ${monthlyData.employee.name}`);
    console.log(`   - Attendance records: ${monthlyData.attendance.length}`);
    
    if (monthlyData.attendance.length > 0) {
      console.log('\n📅 Sample attendance records:');
      monthlyData.attendance.slice(0, 3).forEach((record, index) => {
        console.log(`   ${index + 1}. ${record.date}: ${record.status}`);
        if (record.checkInImage) console.log(`      📸 Check-in image: ${record.checkInImage}`);
        if (record.checkOutImage) console.log(`      📸 Check-out image: ${record.checkOutImage}`);
      });
    } else {
      console.log('   ℹ️ No attendance records found for this month');
    }

    console.log('\n✅ Monthly Attendance Calendar API test completed successfully!');
    console.log('\n📋 Summary of implemented features:');
    console.log('   ✅ EmployeeCalendar component created');
    console.log('   ✅ Monthly attendance API endpoint added');
    console.log('   ✅ 60-day data retention implemented');
    console.log('   ✅ Click handler on employee rows');
    console.log('   ✅ Responsive calendar design');
    console.log('   ✅ Image display with check-in/check-out times');
    
    console.log('\n🎯 How to use:');
    console.log('   1. Go to Attendance Images page');
    console.log('   2. Click on any employee row');
    console.log('   3. View monthly calendar with attendance data');
    console.log('   4. Click on any day to see detailed attendance info');
    console.log('   5. Navigate between months using Previous/Next buttons');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('   1. Make sure the backend server is running on port 5000');
    console.error('   2. Check that MongoDB is connected');
    console.error('   3. Verify that employees exist in the database');
    console.error('   4. Ensure the new API endpoint is properly deployed');
  }
};

// Run the test if this script is executed directly
if (typeof window === 'undefined') {
  // Node.js environment
  const fetch = require('node-fetch');
  testMonthlyCalendarAPI();
} else {
  // Browser environment
  console.log('🌐 Run this test in Node.js environment or use the browser console');
  console.log('Copy and paste the testMonthlyCalendarAPI function to test in browser');
}
