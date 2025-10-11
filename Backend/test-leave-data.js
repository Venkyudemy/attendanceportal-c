// Direct database test for leave data integration
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const LeaveRequest = require('./models/LeaveRequest');

const testLeaveDataIntegration = async () => {
  try {
    console.log('🔌 Connecting to MongoDB...');
    
    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/attendanceportal', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB');
    
    // Test 1: Check if there are any approved leave requests
    console.log('\n📋 Testing Leave Request Data...');
    const approvedLeaves = await LeaveRequest.find({ status: 'Approved' });
    console.log(`Found ${approvedLeaves.length} approved leave requests`);
    
    if (approvedLeaves.length > 0) {
      console.log('\n📝 Approved Leave Requests:');
      approvedLeaves.forEach((leave, index) => {
        console.log(`${index + 1}. Employee: ${leave.employeeName} (${leave.employeeEmail})`);
        console.log(`   Leave Type: ${leave.leaveType}`);
        console.log(`   Dates: ${leave.startDate} to ${leave.endDate}`);
        console.log(`   Employee ID: ${leave.employeeId}`);
        console.log(`   Status: ${leave.status}`);
        console.log(`   Admin Response: ${leave.adminResponse}`);
        console.log(`   Admin: ${leave.adminName}`);
        console.log('');
      });
    }
    
    // Test 2: Check employee data
    console.log('\n👥 Testing Employee Data...');
    const employees = await Employee.find({}).select('name email employeeId department salary monthlySalary');
    console.log(`Found ${employees.length} employees`);
    
    if (employees.length > 0) {
      console.log('\n👤 Employee List:');
      employees.forEach((emp, index) => {
        console.log(`${index + 1}. Name: ${emp.name}`);
        console.log(`   Email: ${emp.email}`);
        console.log(`   Employee ID: ${emp.employeeId}`);
        console.log(`   Department: ${emp.department}`);
        console.log(`   Salary: ₹${emp.salary || emp.monthlySalary || 0}`);
        console.log('');
      });
    }
    
    // Test 3: Test employee matching logic
    console.log('\n🔍 Testing Employee Matching Logic...');
    
    if (approvedLeaves.length > 0 && employees.length > 0) {
      const testLeave = approvedLeaves[0];
      console.log(`Testing matching for leave: ${testLeave.employeeName}`);
      
      let matchedEmployee = null;
      const leaveEmployeeId = testLeave.employeeId;
      
      // Strategy 1: Direct ObjectId match
      if (mongoose.Types.ObjectId.isValid(leaveEmployeeId)) {
        matchedEmployee = employees.find(e => e._id.toString() === leaveEmployeeId.toString());
        if (matchedEmployee) {
          console.log('✅ Strategy 1 (ObjectId match) succeeded');
        }
      }
      
      // Strategy 2: Employee ID string match
      if (!matchedEmployee) {
        matchedEmployee = employees.find(e => e.employeeId === leaveEmployeeId);
        if (matchedEmployee) {
          console.log('✅ Strategy 2 (Employee ID match) succeeded');
        }
      }
      
      // Strategy 3: Email match
      if (!matchedEmployee) {
        matchedEmployee = employees.find(e => e.email === testLeave.employeeEmail);
        if (matchedEmployee) {
          console.log('✅ Strategy 3 (Email match) succeeded');
        }
      }
      
      // Strategy 4: Name match
      if (!matchedEmployee) {
        matchedEmployee = employees.find(e => e.name.toLowerCase() === testLeave.employeeName.toLowerCase());
        if (matchedEmployee) {
          console.log('✅ Strategy 4 (Name match) succeeded');
        }
      }
      
      if (matchedEmployee) {
        console.log(`✅ Successfully matched leave to employee: ${matchedEmployee.name} (${matchedEmployee.email})`);
      } else {
        console.log('❌ Failed to match leave to any employee');
        console.log('Available employee IDs:', employees.map(e => e.employeeId));
        console.log('Available employee names:', employees.map(e => e.name));
        console.log('Available employee emails:', employees.map(e => e.email));
      }
    }
    
    // Test 4: Simulate payroll period calculation
    console.log('\n📅 Testing Payroll Period Calculation...');
    
    const now = new Date();
    const payrollStartDate = new Date(now.getFullYear(), now.getMonth(), 23);
    const payrollEndDate = new Date(now.getFullYear(), now.getMonth() + 1, 23);
    
    console.log(`Payroll period: ${payrollStartDate.toISOString().split('T')[0]} to ${payrollEndDate.toISOString().split('T')[0]}`);
    
    // Check which leaves fall within payroll period
    const payrollLeaves = approvedLeaves.filter(leave => {
      const leaveStart = new Date(leave.startDate);
      const leaveEnd = new Date(leave.endDate);
      return leaveStart < payrollEndDate && leaveEnd >= payrollStartDate;
    });
    
    console.log(`Found ${payrollLeaves.length} approved leaves within payroll period`);
    
    if (payrollLeaves.length > 0) {
      console.log('\n📊 Leaves within payroll period:');
      payrollLeaves.forEach((leave, index) => {
        console.log(`${index + 1}. ${leave.employeeName} - ${leave.startDate} to ${leave.endDate}`);
      });
    }
    
    console.log('\n✅ Database integration test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('   1. Make sure MongoDB is running on localhost:27017');
    console.error('   2. Check that the database name is "attendanceportal"');
    console.error('   3. Verify that Employee and LeaveRequest collections exist');
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
  }
};

// Run the test
testLeaveDataIntegration();
