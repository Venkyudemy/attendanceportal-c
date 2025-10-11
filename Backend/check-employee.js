const mongoose = require('mongoose');
const Employee = require('./models/Employee');

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/attendanceportal');
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
};

// Check if employee exists by email
const checkEmployee = async (email) => {
  try {
    console.log(`🔍 Checking for employee with email: ${email}`);
    
    const employee = await Employee.findOne({ email: email });
    
    if (employee) {
      console.log('✅ Employee found:');
      console.log(`   ID: ${employee._id}`);
      console.log(`   Name: ${employee.name}`);
      console.log(`   Email: ${employee.email}`);
      console.log(`   Role: ${employee.role}`);
      console.log(`   Status: ${employee.status}`);
      console.log(`   Department: ${employee.department || 'Not set'}`);
      console.log(`   Position: ${employee.position || 'Not set'}`);
      
      // Check attendance structure
      if (employee.attendance) {
        console.log('   Attendance structure: ✅ Present');
        if (employee.attendance.today) {
          console.log(`   Today's status: ${employee.attendance.today.status || 'Not set'}`);
        }
      } else {
        console.log('   Attendance structure: ❌ Missing');
      }
      
      return employee;
    } else {
      console.log('❌ Employee not found');
      
      // List all employees to help debug
      const allEmployees = await Employee.find({}, 'name email role status');
      console.log('\n📋 All employees in database:');
      allEmployees.forEach((emp, index) => {
        console.log(`   ${index + 1}. ${emp.name} (${emp.email}) - ${emp.role} - ${emp.status}`);
      });
      
      return null;
    }
  } catch (error) {
    console.error('❌ Error checking employee:', error);
    return null;
  }
};

// Create employee if not exists
const createEmployee = async (email, name = 'sai') => {
  try {
    console.log(`🔧 Creating employee: ${name} (${email})`);
    
    const newEmployee = new Employee({
      name: name,
      email: email,
      role: 'employee',
      status: 'Active',
      department: 'IT',
      position: 'Senior',
      attendance: {
        today: {
          status: 'Absent',
          checkIns: [],
          checkOuts: [],
          checkInTime: null,
          checkOutTime: null,
          checkInImage: null,
          checkOutImage: null
        },
        records: []
      },
      leaveBalance: {
        total: 21,
        used: 0,
        remaining: 21
      }
    });
    
    const savedEmployee = await newEmployee.save();
    console.log('✅ Employee created successfully:');
    console.log(`   ID: ${savedEmployee._id}`);
    console.log(`   Name: ${savedEmployee.name}`);
    console.log(`   Email: ${savedEmployee.email}`);
    
    return savedEmployee;
  } catch (error) {
    console.error('❌ Error creating employee:', error);
    return null;
  }
};

// Main function
const main = async () => {
  await connectDB();
  
  // Get email from command line argument or use default
  const email = process.argv[2] || 'sai@example.com';
  
  console.log('='.repeat(60));
  console.log('🔍 EMPLOYEE DATABASE CHECK');
  console.log('='.repeat(60));
  
  let employee = await checkEmployee(email);
  
  if (!employee) {
    console.log('\n🔧 Creating missing employee...');
    employee = await createEmployee(email);
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('✅ CHECK COMPLETE');
  console.log('='.repeat(60));
  
  process.exit(0);
};

main().catch(error => {
  console.error('❌ Script error:', error);
  process.exit(1);
});


