// Test script for payroll and leave integration
console.log('🧪 Testing Payroll and Leave Integration...\n');

const testPayrollLeaveIntegration = async () => {
  try {
    console.log('1. Testing Leave Data Fetch...');
    
    // Test fetching approved leave requests
    const leaveResponse = await fetch('http://localhost:5000/api/leave-requests?status=Approved');
    
    if (!leaveResponse.ok) {
      throw new Error(`Failed to fetch leave requests: ${leaveResponse.status}`);
    }
    
    const leaveData = await leaveResponse.json();
    console.log(`✅ Found ${leaveData.length} approved leave requests`);
    
    if (leaveData.length > 0) {
      console.log('\n📋 Approved Leave Requests:');
      leaveData.forEach((leave, index) => {
        console.log(`${index + 1}. ${leave.employeeName} (${leave.employeeEmail})`);
        console.log(`   Leave Type: ${leave.leaveType}`);
        console.log(`   Dates: ${leave.startDate} to ${leave.endDate} (${leave.totalDays} days)`);
        console.log(`   Status: ${leave.status}`);
        console.log(`   Employee ID: ${leave.employeeId}`);
      });
    }
    
    console.log('\n2. Testing Employee Data Fetch...');
    
    // Test fetching all employees
    const employeeResponse = await fetch('http://localhost:5000/api/employee');
    
    if (!employeeResponse.ok) {
      throw new Error(`Failed to fetch employees: ${employeeResponse.status}`);
    }
    
    const employees = await employeeResponse.json();
    console.log(`✅ Found ${employees.length} employees`);
    
    if (employees.length > 0) {
      console.log('\n👥 Employee Data:');
      employees.forEach((emp, index) => {
        console.log(`${index + 1}. ${emp.name} (${emp.email})`);
        console.log(`   Employee ID: ${emp.employeeId}`);
        console.log(`   Department: ${emp.department}`);
        console.log(`   Salary: ₹${emp.salary || 0}`);
      });
    }
    
    console.log('\n3. Testing Payroll Calculation...');
    
    // Test payroll calculation for current period
    const payrollResponse = await fetch('http://localhost:5000/api/employee/payroll/calculate');
    
    if (!payrollResponse.ok) {
      throw new Error(`Failed to calculate payroll: ${payrollResponse.status}`);
    }
    
    const payrollData = await payrollResponse.json();
    console.log(`✅ Payroll calculation completed for ${payrollData.payrollData.length} employees`);
    
    console.log('\n📊 Payroll Summary:');
    console.log(`   Period: ${new Date(payrollData.payrollPeriod.startDate).toLocaleDateString()} to ${new Date(payrollData.payrollPeriod.endDate).toLocaleDateString()}`);
    console.log(`   Total Working Days: ${payrollData.totalWorkingDays}`);
    console.log(`   Late Penalty: ₹${payrollData.fixedLatePenalty} per day`);
    
    console.log('\n💰 Employee Payroll Details:');
    payrollData.payrollData.forEach((emp, index) => {
      console.log(`${index + 1}. ${emp.name} (${emp.email})`);
      console.log(`   Monthly Salary: ₹${emp.monthlySalary}`);
      console.log(`   Full Days: ${emp.fullDays}`);
      console.log(`   Late Days: ${emp.lateDays}`);
      console.log(`   Absent Days: ${emp.absents}`);
      console.log(`   Leave Days: ${emp.leaveDays}`);
      console.log(`   LOP Amount: ₹${emp.lopAmount}`);
      console.log(`   Final Pay: ₹${emp.finalPay}`);
      
      if (emp.leaveDays > 0) {
        console.log(`   ✅ Leave days correctly calculated: ${emp.leaveDays}`);
      } else {
        console.log(`   ⚠️ No leave days found - check integration`);
      }
    });
    
    // Check if leave data is properly integrated
    const employeesWithLeaves = payrollData.payrollData.filter(emp => emp.leaveDays > 0);
    console.log(`\n📈 Integration Summary:`);
    console.log(`   Employees with leave days: ${employeesWithLeaves.length}`);
    console.log(`   Total leave requests: ${leaveData.length}`);
    
    if (employeesWithLeaves.length > 0) {
      console.log('✅ Leave integration is working correctly!');
    } else if (leaveData.length > 0) {
      console.log('❌ Leave integration issue detected - approved leaves not reflected in payroll');
    } else {
      console.log('ℹ️ No approved leaves found for current period');
    }
    
    console.log('\n✅ Payroll and Leave Integration test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('   1. Make sure the backend server is running on port 5000');
    console.error('   2. Check that MongoDB is connected');
    console.error('   3. Verify that employees and leave requests exist');
    console.error('   4. Check the payroll calculation endpoint');
  }
};

// Run the test if this script is executed directly
if (typeof window === 'undefined') {
  // Node.js environment
  const fetch = require('node-fetch');
  testPayrollLeaveIntegration();
} else {
  // Browser environment
  console.log('🌐 Run this test in Node.js environment or use the browser console');
  console.log('Copy and paste the testPayrollLeaveIntegration function to test in browser');
}
