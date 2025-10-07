const mongoose = require('mongoose');
const Employee = require('./models/Employee');

// MongoDB Connection
const MONGO_URI = process.env.MONGO_URL || 'mongodb://localhost:27017/attendanceportal';

console.log('🔗 Testing MongoDB connection...');
console.log('📡 MongoDB URI:', MONGO_URI);

mongoose.connect(MONGO_URI, { 
  useNewUrlParser: true, 
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000
})
.then(async () => {
  console.log('✅ Connected to MongoDB successfully');
  console.log('📊 Database:', mongoose.connection.db.databaseName);
  console.log('🌐 Host:', mongoose.connection.host);
  console.log('🔌 Port:', mongoose.connection.port);
  
  // Test: Fetch all employees
  console.log('\n📋 Fetching employees...');
  const employees = await Employee.find({});
  console.log(`✅ Found ${employees.length} employees\n`);
  
  // Show each employee's attendance data
  employees.forEach((emp, idx) => {
    console.log(`${idx + 1}. ${emp.name} (ID: ${emp._id})`);
    console.log(`   Email: ${emp.email}`);
    console.log(`   Today's Date: ${emp.attendance?.today?.date || 'Not set'}`);
    console.log(`   Check-In: ${emp.attendance?.today?.checkIn || 'None'}`);
    console.log(`   Check-In Image: ${emp.attendance?.today?.checkInImage || '❌ NULL'}`);
    console.log(`   Check-Out: ${emp.attendance?.today?.checkOut || 'None'}`);
    console.log(`   Check-Out Image: ${emp.attendance?.today?.checkOutImage || '❌ NULL'}`);
    console.log(`   Records: ${emp.attendance?.records?.length || 0}`);
    console.log('');
  });
  
  // Test: Try to update an employee with image path
  if (employees.length > 0) {
    const testEmployee = employees[0];
    console.log(`\n🧪 Testing image save for: ${testEmployee.name}`);
    
    const testImagePath = `/uploads/employees/${testEmployee._id}/test_checkin.jpg`;
    testEmployee.attendance.today.checkInImage = testImagePath;
    testEmployee.attendance.today.date = new Date().toLocaleDateString('en-CA');
    
    await testEmployee.save();
    console.log('✅ Test save successful!');
    
    // Verify it saved
    const savedEmployee = await Employee.findById(testEmployee._id);
    if (savedEmployee.attendance.today.checkInImage === testImagePath) {
      console.log('✅ VERIFICATION PASSED: Image path saved and retrieved correctly!');
      console.log(`   Saved path: ${savedEmployee.attendance.today.checkInImage}`);
    } else {
      console.log('❌ VERIFICATION FAILED: Image path not saved correctly');
    }
    
    // Clean up test
    savedEmployee.attendance.today.checkInImage = null;
    await savedEmployee.save();
    console.log('🧹 Test cleanup complete');
  }
  
  console.log('\n✅ Database test completed successfully!');
  console.log('🎯 MongoDB is working and can save image paths!\n');
  
  process.exit(0);
})
.catch((err) => {
  console.error('❌ MongoDB connection error:', err.message);
  console.error('\n💡 Solutions:');
  console.error('1. Make sure MongoDB is running:');
  console.error('   - Docker: docker run -d -p 27017:27017 mongo:6');
  console.error('   - Local: mongod --dbpath C:\\data\\db');
  console.error('2. Check if port 27017 is available');
  console.error('3. Verify MongoDB is installed\n');
  process.exit(1);
});

