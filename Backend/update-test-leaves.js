// Update test leave requests to fall within current payroll period
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const LeaveRequest = require('./models/LeaveRequest');

const updateTestLeaves = async () => {
  try {
    console.log('🔌 Connecting to MongoDB...');
    
    await mongoose.connect('mongodb://localhost:27017/attendanceportal', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB');
    
    // Calculate current payroll period (23rd to 23rd)
    const now = new Date();
    const payrollStartDate = new Date(now.getFullYear(), now.getMonth(), 23);
    const payrollEndDate = new Date(now.getFullYear(), now.getMonth() + 1, 23);
    
    console.log(`Current payroll period: ${payrollStartDate.toISOString().split('T')[0]} to ${payrollEndDate.toISOString().split('T')[0]}`);
    
    // Get employees
    const employees = await Employee.find({}).select('name email employeeId');
    
    // Delete existing test leaves
    await LeaveRequest.deleteMany({});
    console.log('🗑️ Deleted existing test leave requests');
    
    // Create new test leaves within the current payroll period
    const testLeaves = [
      {
        employeeId: employees[1]._id, // sai
        employeeName: employees[1].name,
        employeeEmail: employees[1].email,
        leaveType: 'annual leave',
        startDate: '2025-10-25', // Within payroll period
        endDate: '2025-10-27',   // 3 days
        totalDays: 3,
        reason: 'Personal work - updated for payroll test',
        status: 'Approved',
        adminResponse: 'Approved by Admin User',
        adminId: employees[0]._id,
        adminName: 'Admin User',
        requestedAt: new Date(),
        respondedAt: new Date()
      },
      {
        employeeId: employees[2]._id, // suresh
        employeeName: employees[2].name,
        employeeEmail: employees[2].email,
        leaveType: 'annual leave',
        startDate: '2025-10-30', // Within payroll period
        endDate: '2025-10-30',   // 1 day
        totalDays: 1,
        reason: 'Sick leave - updated for payroll test',
        status: 'Approved',
        adminResponse: 'Take rest',
        adminId: employees[0]._id,
        adminName: 'Admin User',
        requestedAt: new Date(),
        respondedAt: new Date()
      }
    ];
    
    console.log('\n📝 Creating updated test leave requests within payroll period...');
    
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
    
    // Verify the updated leave requests
    console.log('\n🔍 Verifying updated leave requests...');
    const allLeaves = await LeaveRequest.find({});
    console.log(`Total leave requests in database: ${allLeaves.length}`);
    
    const approvedLeaves = await LeaveRequest.find({ status: 'Approved' });
    console.log(`Approved leave requests: ${approvedLeaves.length}`);
    
    // Check which leaves fall within payroll period
    const payrollLeaves = approvedLeaves.filter(leave => {
      const leaveStart = new Date(leave.startDate);
      const leaveEnd = new Date(leave.endDate);
      return leaveStart < payrollEndDate && leaveEnd >= payrollStartDate;
    });
    
    console.log(`Leaves within payroll period: ${payrollLeaves.length}`);
    
    if (payrollLeaves.length > 0) {
      console.log('\n✅ Leaves within payroll period:');
      payrollLeaves.forEach((leave, index) => {
        console.log(`${index + 1}. ${leave.employeeName} - ${leave.startDate} to ${leave.endDate} (${leave.totalDays} days)`);
      });
    }
    
    console.log('\n✅ Test leave requests updated successfully!');
    console.log('\n🎯 Ready to test payroll integration!');
    
  } catch (error) {
    console.error('❌ Error updating test leave requests:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
  }
};

updateTestLeaves();
