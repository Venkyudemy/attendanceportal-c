// Create the actual leave requests that match the Leave Management interface
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const LeaveRequest = require('./models/LeaveRequest');

const createRealLeaves = async () => {
  try {
    console.log('🔌 Connecting to MongoDB...');
    
    await mongoose.connect('mongodb://localhost:27017/attendanceportal', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB');
    
    // Get employees
    const employees = await Employee.find({}).select('name email employeeId');
    console.log(`Found ${employees.length} employees`);
    
    // Find specific employees by email
    let madhuEmployee = employees.find(emp => emp.email === 'madhu@gmail.com');
    const saiEmployee = employees.find(emp => emp.email === 'sai@gmail.com');
    const adminEmployee = employees.find(emp => emp.email === 'admin@techcorp.com');
    
    if (!madhuEmployee) {
      console.log('❌ Madhu employee not found. Creating Madhu employee...');
      // Create Madhu employee if not exists
      const newMadhu = new Employee({
        name: 'madhu',
        email: 'madhu@gmail.com',
        employeeId: '003',
        department: 'Engineering',
        position: 'Developer',
        phone: '9999999999',
        password: 'hashedpassword',
        salary: 50000,
        monthlySalary: 50000,
        attendance: {
          today: { checkIn: null, checkOut: null, status: 'Absent', isLate: false, date: null },
          records: []
        },
        leaveBalance: {
          annual: { total: 12, used: 0, remaining: 12 },
          sick: { total: 6, used: 0, remaining: 6 },
          personal: { total: 3, used: 0, remaining: 3 }
        }
      });
      await newMadhu.save();
      console.log('✅ Created Madhu employee');
      madhuEmployee = newMadhu;
    }
    
    if (!saiEmployee) {
      console.log('❌ Sai employee not found');
    }
    
    if (!adminEmployee) {
      console.log('❌ Admin employee not found');
    }
    
    // Delete existing test leaves
    await LeaveRequest.deleteMany({});
    console.log('🗑️ Deleted existing test leave requests');
    
    // Create the actual leave requests that match your Leave Management interface
    const realLeaves = [
      {
        employeeId: madhuEmployee._id,
        employeeName: 'madhu',
        employeeEmail: 'madhu@gmail.com',
        leaveType: 'annual leave',
        startDate: '2025-10-13',
        endDate: '2025-10-13',
        totalDays: 1,
        reason: 'sick leave',
        status: 'Approved',
        adminResponse: 'ok take rest',
        adminId: adminEmployee ? adminEmployee._id : null,
        adminName: 'Admin User',
        requestedAt: new Date('2025-10-10'),
        respondedAt: new Date('2025-10-10')
      },
      {
        employeeId: saiEmployee._id,
        employeeName: 'sai',
        employeeEmail: 'sai@gmail.com',
        leaveType: 'annual leave',
        startDate: '2025-10-09',
        endDate: '2025-10-11',
        totalDays: 3,
        reason: 'Jsjsjd',
        status: 'Approved',
        adminResponse: 'Approved',
        adminId: adminEmployee ? adminEmployee._id : null,
        adminName: 'Admin User',
        requestedAt: new Date('2025-10-08'),
        respondedAt: new Date('2025-10-08')
      }
    ];
    
    console.log('\n📝 Creating REAL leave requests from Leave Management interface...');
    
    for (const leaveData of realLeaves) {
      try {
        if (leaveData.employeeId) {
          const leaveRequest = new LeaveRequest(leaveData);
          const savedRequest = await leaveRequest.save();
          
          console.log(`✅ Created leave request for ${leaveData.employeeName}:`);
          console.log(`   Dates: ${leaveData.startDate} to ${leaveData.endDate} (${leaveData.totalDays} days)`);
          console.log(`   Status: ${leaveData.status}`);
          console.log(`   Reason: ${leaveData.reason}`);
          console.log(`   Admin Response: ${leaveData.adminResponse}`);
          console.log(`   ID: ${savedRequest._id}`);
          console.log('');
        } else {
          console.log(`❌ Skipping ${leaveData.employeeName} - employee not found`);
        }
      } catch (error) {
        console.error(`❌ Failed to create leave request for ${leaveData.employeeName}:`, error.message);
      }
    }
    
    // Verify the created leave requests
    console.log('\n🔍 Verifying REAL leave requests...');
    const allLeaves = await LeaveRequest.find({});
    console.log(`Total leave requests in database: ${allLeaves.length}`);
    
    const approvedLeaves = await LeaveRequest.find({ status: 'Approved' });
    console.log(`Approved leave requests: ${approvedLeaves.length}`);
    
    if (approvedLeaves.length > 0) {
      console.log('\n✅ REAL Approved Leave Requests:');
      approvedLeaves.forEach((leave, index) => {
        console.log(`${index + 1}. ${leave.employeeName} (${leave.employeeEmail})`);
        console.log(`   Dates: ${leave.startDate} to ${leave.endDate} (${leave.totalDays} days)`);
        console.log(`   Reason: ${leave.reason}`);
        console.log(`   Admin Response: ${leave.adminResponse}`);
      });
    }
    
    console.log('\n✅ REAL leave requests created successfully!');
    console.log('\n🎯 These match your Leave Management interface:');
    console.log('   - Madhu: 1 day (10/13/2025) - sick leave');
    console.log('   - Sai: 3 days (10/9/2025 to 10/11/2025) - Jsjsjd');
    
  } catch (error) {
    console.error('❌ Error creating real leave requests:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
  }
};

createRealLeaves();
