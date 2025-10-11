// Check all leave requests regardless of status
const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const LeaveRequest = require('./models/LeaveRequest');

const checkAllLeaves = async () => {
  try {
    console.log('🔌 Connecting to MongoDB...');
    
    await mongoose.connect('mongodb://localhost:27017/attendanceportal', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB');
    
    // Check ALL leave requests regardless of status
    console.log('\n📋 Checking ALL Leave Requests...');
    const allLeaves = await LeaveRequest.find({});
    console.log(`Found ${allLeaves.length} total leave requests`);
    
    if (allLeaves.length > 0) {
      console.log('\n📝 All Leave Requests:');
      allLeaves.forEach((leave, index) => {
        console.log(`${index + 1}. Employee: ${leave.employeeName} (${leave.employeeEmail})`);
        console.log(`   Leave Type: ${leave.leaveType}`);
        console.log(`   Dates: ${leave.startDate} to ${leave.endDate}`);
        console.log(`   Employee ID: ${leave.employeeId}`);
        console.log(`   Status: ${leave.status}`);
        console.log(`   Admin Response: ${leave.adminResponse || 'None'}`);
        console.log(`   Admin: ${leave.adminName || 'None'}`);
        console.log(`   Requested At: ${leave.requestedAt}`);
        console.log(`   Responded At: ${leave.respondedAt || 'Not responded'}`);
        console.log('');
      });
      
      // Group by status
      const statusCounts = {};
      allLeaves.forEach(leave => {
        statusCounts[leave.status] = (statusCounts[leave.status] || 0) + 1;
      });
      
      console.log('📊 Status Summary:');
      Object.entries(statusCounts).forEach(([status, count]) => {
        console.log(`   ${status}: ${count} requests`);
      });
      
    } else {
      console.log('❌ No leave requests found in database!');
      console.log('\n🔧 Possible issues:');
      console.log('   1. Leave requests are not being saved to database');
      console.log('   2. Wrong collection name');
      console.log('   3. Wrong database name');
      console.log('   4. Leave requests are stored in a different collection');
    }
    
    // Check if there are any other collections that might contain leave data
    console.log('\n🗂️ Checking all collections in database...');
    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();
    
    console.log('Available collections:');
    collections.forEach(col => {
      console.log(`   - ${col.name}`);
    });
    
    // Check if there are any documents in other collections that might be leave data
    for (const col of collections) {
      if (col.name.toLowerCase().includes('leave')) {
        console.log(`\n📄 Checking collection: ${col.name}`);
        const collection = db.collection(col.name);
        const count = await collection.countDocuments();
        console.log(`   Document count: ${count}`);
        
        if (count > 0) {
          const sample = await collection.findOne();
          console.log(`   Sample document:`, JSON.stringify(sample, null, 2));
        }
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
  }
};

checkAllLeaves();
