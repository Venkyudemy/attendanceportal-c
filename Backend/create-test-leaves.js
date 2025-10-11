// Create test leave requests to verify the approval and payroll integration
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const LeaveRequest = require('./models/LeaveRequest');

const createTestLeaves = async () => {
  try {
    console.log('🔌 Connecting to MongoDB...');
    
    await mongoose.connect('mongodb://localhost:27017/attendanceportal', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB');
    
    // Get employees to create leave requests for
    const employees = await Employee.find({}).select('name email employeeId');
    console.log(`Found ${employees.length} employees`);
    
    if (employees.length === 0) {
      console.log('❌ No employees found. Cannot create test leave requests.');
      return;
    }
    
    // Create test leave requests for October 2025 (current payroll period)
    const testLeaves = [
      {
        employeeId: employees[1]._id, // Second employee (sai)
        employeeName: employees[1].name,
        employeeEmail: employees[1].email,
        leaveType: 'annual leave',
        startDate: '2025-10-09',
        endDate: '2025-10-11',
        totalDays: 3,
        reason: 'Personal work',
        status: 'Approved',
        adminResponse: 'Approved by Admin User',
        adminId: employees[0]._id, // Admin user
        adminName: 'Admin User',
        requestedAt: new Date('2025-10-08'),
        respondedAt: new Date('2025-10-08')
      },
      {
        employeeId: employees[2]._id, // Third employee (suresh)
        employeeName: employees[2].name,
        employeeEmail: employees[2].email,
        leaveType: 'annual leave',
        startDate: '2025-10-13',
        endDate: '2025-10-13',
        totalDays: 1,
        reason: 'Sick leave',
        status: 'Approved',
        adminResponse: 'Take rest',
        adminId: employees[0]._id, // Admin user
        adminName: 'Admin User',
        requestedAt: new Date('2025-10-10'),
        respondedAt: new Date('2025-10-10')
      }
    ];
    
    console.log('\n📝 Creating test leave requests...');
    
    for (const leaveData of testLeaves) {
      try {
        const leaveRequest = new LeaveRequest(leaveData);
        const savedRequest = await leaveRequest.save();
        
        console.log(`✅ Created leave request for ${leaveData.employeeName}:`);
        console.log(`   Dates: ${leaveData.startDate} to ${leaveData.endDate} (${leaveData.totalDays} days)`);
        console.log(`   Status: ${leaveData.status}`);
        console.log(`   ID: ${savedRequest._id}`);
        console.log('');
        
      } catch (error) {
        console.error(`❌ Failed to create leave request for ${leaveData.employeeName}:`, error.message);
      }
    }
    
    // Verify the created leave requests
    console.log('\n🔍 Verifying created leave requests...');
    const allLeaves = await LeaveRequest.find({});
    console.log(`Total leave requests in database: ${allLeaves.length}`);
    
    const approvedLeaves = await LeaveRequest.find({ status: 'Approved' });
    console.log(`Approved leave requests: ${approvedLeaves.length}`);
    
    if (approvedLeaves.length > 0) {
      console.log('\n✅ Approved Leave Requests:');
      approvedLeaves.forEach((leave, index) => {
        console.log(`${index + 1}. ${leave.employeeName} - ${leave.startDate} to ${leave.endDate} (${leave.totalDays} days)`);
      });
    }
    
    console.log('\n✅ Test leave requests created successfully!');
    console.log('\n🎯 Next steps:');
    console.log('   1. Test the payroll calculation to see if leaves are now included');
    console.log('   2. Verify that the Leave Management interface shows these leaves');
    console.log('   3. Check that the payroll shows correct leave days and reduced LOP');
    
  } catch (error) {
    console.error('❌ Error creating test leave requests:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
  }
};

createTestLeaves();
