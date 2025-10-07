const mongoose = require('mongoose');
const Employee = require('./models/Employee');

// MongoDB Connection
const MONGO_URI = process.env.MONGO_URL || 'mongodb://localhost:27017/attendanceportal';

console.log('🔍 Checking database for image storage...\n');

mongoose.connect(MONGO_URI, { 
  useNewUrlParser: true, 
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000
})
.then(async () => {
  console.log('✅ Connected to MongoDB\n');
  
  // Get employee 'sai'
  const sai = await Employee.findOne({ email: 'sai@gmail.com' });
  
  if (!sai) {
    console.log('❌ Employee "sai" not found in database!');
    process.exit(1);
  }
  
  console.log('═══════════════════════════════════════════');
  console.log('📊 EMPLOYEE: ' + sai.name);
  console.log('📧 Email: ' + sai.email);
  console.log('🆔 ID: ' + sai._id);
  console.log('═══════════════════════════════════════════\n');
  
  console.log('📅 TODAY\'S ATTENDANCE:');
  console.log('─────────────────────────────────────────');
  console.log('Date:', sai.attendance?.today?.date || '❌ Not set');
  console.log('Check-In Time:', sai.attendance?.today?.checkIn || '❌ None');
  console.log('Check-In Image:', sai.attendance?.today?.checkInImage || '❌ NULL');
  console.log('Check-Out Time:', sai.attendance?.today?.checkOut || '❌ None');
  console.log('Check-Out Image:', sai.attendance?.today?.checkOutImage || '❌ NULL');
  console.log('Status:', sai.attendance?.today?.status || 'Unknown');
  console.log('');
  
  console.log('📚 HISTORICAL RECORDS: ' + (sai.attendance?.records?.length || 0));
  console.log('─────────────────────────────────────────');
  
  if (sai.attendance?.records && sai.attendance.records.length > 0) {
    sai.attendance.records.forEach((record, idx) => {
      console.log(`\nRecord ${idx + 1}:`);
      console.log('  Date:', record.date);
      console.log('  Check-In:', record.checkIn || 'None');
      console.log('  Check-In Image:', record.checkInImage || '❌ NULL');
      console.log('  Check-Out:', record.checkOut || 'None');
      console.log('  Check-Out Image:', record.checkOutImage || '❌ NULL');
      console.log('  Status:', record.status);
      console.log('  Hours:', record.hours || 0);
    });
  } else {
    console.log('  No historical records found');
  }
  
  console.log('\n═══════════════════════════════════════════');
  console.log('📸 IMAGE STORAGE SUMMARY:');
  console.log('═══════════════════════════════════════════');
  
  const hasCheckInImage = !!(sai.attendance?.today?.checkInImage);
  const hasCheckOutImage = !!(sai.attendance?.today?.checkOutImage);
  
  if (hasCheckInImage) {
    console.log('✅ Check-In Image SAVED in database');
    console.log('   Path:', sai.attendance.today.checkInImage);
  } else {
    console.log('❌ Check-In Image NOT in database');
  }
  
  if (hasCheckOutImage) {
    console.log('✅ Check-Out Image SAVED in database');
    console.log('   Path:', sai.attendance.today.checkOutImage);
  } else {
    console.log('❌ Check-Out Image NOT in database');
  }
  
  console.log('\n═══════════════════════════════════════════');
  
  if (hasCheckInImage || hasCheckOutImage) {
    console.log('🎉 SUCCESS! Images are being saved to database!');
    console.log('');
    console.log('💡 Next Steps:');
    console.log('1. Make sure backend is running: npm start');
    console.log('2. Go to Admin Panel → Attendance Images');
    console.log('3. Refresh page (Ctrl+F5)');
    console.log('4. Images should appear in table!');
  } else {
    console.log('⚠️ WARNING: No images found in database!');
    console.log('');
    console.log('💡 To fix:');
    console.log('1. Make sure backend is running');
    console.log('2. Login as employee (sai@gmail.com)');
    console.log('3. Click "Check In" button');
    console.log('4. Camera opens → Capture photo → Confirm');
    console.log('5. Run this test again');
  }
  
  console.log('\n');
  process.exit(0);
})
.catch((err) => {
  console.error('❌ MongoDB connection error:', err.message);
  console.error('\n💡 Make sure MongoDB is running:');
  console.error('   docker run -d -p 27017:27017 mongo:6');
  console.error('   OR: mongod');
  process.exit(1);
});
