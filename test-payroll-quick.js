// Quick test to verify payroll fix is working
const fetch = require('node-fetch');

async function testPayrollFix() {
  console.log('🧪 Testing Payroll Fix...\n');
  
  try {
    // Test the new fixed endpoint
    const response = await fetch('http://localhost:5000/api/employee/payroll/calculate-fixed');
    
    if (!response.ok) {
      throw new Error(`Server error: ${response.status}`);
    }
    
    const data = await response.json();
    console.log(`✅ Payroll calculation completed for ${data.payrollData.length} employees`);
    console.log(`📋 Leave requests processed: ${data.leaveRequestsProcessed}`);
    
    console.log('\n💰 Payroll Results:');
    console.log('='.repeat(60));
    
    data.payrollData.forEach(emp => {
      console.log(`${emp.name} (${emp.email}):`);
      console.log(`  Leave Days: ${emp.leaveDays} ${emp.leaveDays > 0 ? '✅' : '❌'}`);
      console.log(`  LOP Amount: ₹${emp.lopAmount}`);
      console.log(`  Final Pay: ₹${emp.finalPay}`);
      console.log('');
    });
    
    // Check if fix worked
    const employeesWithLeaves = data.payrollData.filter(emp => emp.leaveDays > 0);
    
    if (employeesWithLeaves.length > 0) {
      console.log(`🎉 SUCCESS! ${employeesWithLeaves.length} employees have leave days correctly calculated.`);
      console.log('✅ The payroll fix is working!');
    } else {
      console.log('❌ Leave days are still 0. Check server restart and database connection.');
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.log('\n🔧 Make sure:');
    console.log('   1. Backend server is running on port 5000');
    console.log('   2. Server was restarted after the fix');
    console.log('   3. MongoDB is connected');
  }
}

testPayrollFix();
