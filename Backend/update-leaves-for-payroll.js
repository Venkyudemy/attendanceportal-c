// Update the real leave requests to fall within the current payroll period
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const LeaveRequest = require('./models/LeaveRequest');

const updateLeavesForPayroll = async () => {
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
    
    // Get all leave requests
    const allLeaves = await LeaveRequest.find({});
    console.log(`Found ${allLeaves.length} leave requests`);
    
    // Update leave dates to fall within payroll period
    const updates = [
      {
        filter: { employeeEmail: 'madhu@gmail.com' },
        update: {
          startDate: '2025-10-25',
          endDate: '2025-10-25',
          totalDays: 1
        }
      },
      {
        filter: { employeeEmail: 'sai@gmail.com' },
        update: {
          startDate: '2025-10-26',
          endDate: '2025-10-28',
          totalDays: 3
        }
      }
    ];
    
    console.log('\n📝 Updating leave dates to fall within payroll period...');
    
    for (const { filter, update } of updates) {
      const result = await LeaveRequest.updateOne(filter, update);
      console.log(`✅ Updated ${filter.employeeEmail}: ${update.startDate} to ${update.endDate} (${update.totalDays} days)`);
    }
    
    // Verify the updated leave requests
    console.log('\n🔍 Verifying updated leave requests...');
    const updatedLeaves = await LeaveRequest.find({});
    
    console.log('\n✅ Updated Leave Requests:');
    updatedLeaves.forEach((leave, index) => {
      console.log(`${index + 1}. ${leave.employeeName} (${leave.employeeEmail})`);
      console.log(`   Dates: ${leave.startDate} to ${leave.endDate} (${leave.totalDays} days)`);
      console.log(`   Status: ${leave.status}`);
      console.log(`   Reason: ${leave.reason}`);
      console.log(`   Admin Response: ${leave.adminResponse}`);
    });
    
    // Check which leaves fall within payroll period
    const payrollLeaves = updatedLeaves.filter(leave => {
      const leaveStart = new Date(leave.startDate);
      const leaveEnd = new Date(leave.endDate);
      return leaveStart < payrollEndDate && leaveEnd >= payrollStartDate;
    });
    
    console.log(`\n📅 Leaves within payroll period: ${payrollLeaves.length}`);
    
    if (payrollLeaves.length > 0) {
      console.log('\n✅ Leaves that will appear in payroll:');
      payrollLeaves.forEach((leave, index) => {
        console.log(`${index + 1}. ${leave.employeeName} - ${leave.startDate} to ${leave.endDate} (${leave.totalDays} days)`);
      });
    }
    
    console.log('\n✅ Leave requests updated successfully!');
    console.log('\n🎯 Now the payroll should show:');
    console.log('   - madhu: 1 leave day');
    console.log('   - sai: 3 leave days');
    
  } catch (error) {
    console.error('❌ Error updating leave requests:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
  }
};

updateLeavesForPayroll();
