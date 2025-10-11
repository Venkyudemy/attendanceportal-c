// Direct test of payroll calculation logic

// Mock data based on the images you showed
const mockEmployees = [
  {
    _id: 'emp1',
    name: 'madhu',
    email: 'madhu@gmail.com',
    department: 'Engineering',
    monthlySalary: 0,
    salary: 0,
    employeeId: 'EMP001',
    attendance: {
      records: [
        { date: '2025-10-01', status: 'Absent' },
        { date: '2025-10-02', status: 'Absent' },
        // ... more records showing mostly absent
        { date: '2025-10-13', status: 'Present', isLate: true } // 1 late day
      ]
    }
  },
  {
    _id: 'emp2', 
    name: 'sai',
    email: 'sai@gmail.com',
    department: 'Engineering',
    monthlySalary: 0,
    salary: 0,
    employeeId: 'EMP002',
    attendance: {
      records: [
        { date: '2025-10-01', status: 'Absent' },
        { date: '2025-10-02', status: 'Absent' },
        // ... more records showing mostly absent
        { date: '2025-10-09', status: 'Present', isLate: true },
        { date: '2025-10-10', status: 'Present', isLate: true },
        { date: '2025-10-11', status: 'Present', isLate: true } // 3 late days
      ]
    }
  }
];

const mockLeaveData = [
  {
    _id: 'leave1',
    employeeId: 'EMP001', // This should match madhu
    employeeName: 'madhu',
    employeeEmail: 'madhu@gmail.com',
    startDate: '2025-10-13',
    endDate: '2025-10-13',
    status: 'Approved',
    totalDays: 1
  },
  {
    _id: 'leave2',
    employeeId: 'EMP002', // This should match sai
    employeeName: 'sai', 
    employeeEmail: 'sai@gmail.com',
    startDate: '2025-10-09',
    endDate: '2025-10-11',
    status: 'Approved',
    totalDays: 3
  }
];

// Test the fixed logic
function testPayrollCalculation() {
  console.log('🧪 Testing Fixed Payroll Calculation Logic...\n');
  
  const payrollStartDate = new Date('2025-10-01');
  const payrollEndDate = new Date('2025-10-31');
  const totalWorkingDays = 22;
  const fixedLatePenalty = 200;
  
  const payrollStats = {};
  
  // Initialize payroll stats
  mockEmployees.forEach(emp => {
    const empId = emp._id.toString();
    const monthlySalary = emp.monthlySalary || parseFloat(emp.salary) || 0;
    
    payrollStats[empId] = {
      employeeId: emp.employeeId || empId,
      name: emp.name,
      email: emp.email,
      department: emp.department,
      monthlySalary: monthlySalary,
      fullDays: 0,
      lateDays: 0,
      absents: 0,
      leaveDays: 0,
      lopAmount: 0,
      finalPay: 0
    };
  });
  
  // Process attendance records
  mockEmployees.forEach(emp => {
    const empId = emp._id.toString();
    const attendanceRecords = emp.attendance.records || [];
    
    const periodRecords = attendanceRecords.filter(record => {
      const recordDate = new Date(record.date);
      return recordDate >= payrollStartDate && recordDate < payrollEndDate;
    });

    periodRecords.forEach(record => {
      if (record.status === 'Present' && !record.isLate) {
        payrollStats[empId].fullDays++;
      } else if (record.isLate) {
        payrollStats[empId].lateDays++;
      }
    });
  });
  
  console.log('📊 After processing attendance:');
  Object.values(payrollStats).forEach(emp => {
    console.log(`${emp.name}: Full Days: ${emp.fullDays}, Late Days: ${emp.lateDays}`);
  });
  
  // Process leave data - FIXED VERSION
  console.log('\n📋 Processing leave data...');
  
  mockLeaveData.forEach(leave => {
    console.log(`🔍 Processing leave for: ${leave.employeeName}`);
    
    // Try multiple matching strategies
    let emp = null;
    const leaveEmployeeId = leave.employeeId;
    
    // Strategy 1: Employee ID string match
    emp = mockEmployees.find(e => e.employeeId === leaveEmployeeId);
    
    // Strategy 2: Email match (fallback)
    if (!emp) {
      emp = mockEmployees.find(e => e.email === leave.employeeEmail);
    }
    
    // Strategy 3: Name match (last resort)
    if (!emp) {
      emp = mockEmployees.find(e => e.name.toLowerCase() === leave.employeeName.toLowerCase());
    }
    
    if (emp) {
      const empIdKey = emp._id.toString();
      console.log(`✅ Found matching employee: ${emp.name} (${emp.email})`);
      
      if (payrollStats[empIdKey]) {
        // Calculate leave days within the payroll period
        const leaveStart = new Date(Math.max(new Date(leave.startDate), payrollStartDate));
        const leaveEnd = new Date(Math.min(new Date(leave.endDate), payrollEndDate));
        const leaveDaysCount = Math.ceil((leaveEnd - leaveStart) / (1000 * 60 * 60 * 24)) + 1;
        
        console.log(`📅 Leave calculation: ${leaveDaysCount} days for ${emp.name}`);
        
        if (leaveDaysCount > 0) {
          payrollStats[empIdKey].leaveDays += leaveDaysCount;
          console.log(`✅ Added ${leaveDaysCount} leave days to ${emp.name}. Total: ${payrollStats[empIdKey].leaveDays}`);
        }
      }
    } else {
      console.log(`❌ No matching employee found for: ${leave.employeeName}`);
    }
  });
  
  // Calculate final payroll
  Object.keys(payrollStats).forEach(empId => {
    const stats = payrollStats[empId];
    const perDaySalary = stats.monthlySalary / totalWorkingDays;
    const attendedDays = stats.fullDays + stats.lateDays + stats.leaveDays;
    
    stats.absents = Math.max(0, totalWorkingDays - attendedDays);
    
    const latePenalty = stats.lateDays * fixedLatePenalty;
    const absentPenalty = stats.absents * perDaySalary;
    stats.lopAmount = latePenalty + absentPenalty;
    
    stats.finalPay = Math.max(0, stats.monthlySalary - stats.lopAmount);
    
    stats.lopAmount = Math.round(stats.lopAmount * 100) / 100;
    stats.finalPay = Math.round(stats.finalPay * 100) / 100;
  });
  
  console.log('\n💰 Final Payroll Results:');
  console.log('='.repeat(80));
  Object.values(payrollStats).forEach(emp => {
    console.log(`${emp.name} (${emp.email}):`);
    console.log(`  Monthly Salary: ₹${emp.monthlySalary}`);
    console.log(`  Full Days: ${emp.fullDays}`);
    console.log(`  Late Days: ${emp.lateDays}`);
    console.log(`  Absent Days: ${emp.absents}`);
    console.log(`  Leave Days: ${emp.leaveDays} ${emp.leaveDays > 0 ? '✅' : '❌'}`);
    console.log(`  LOP Amount: ₹${emp.lopAmount}`);
    console.log(`  Final Pay: ₹${emp.finalPay}`);
    console.log('');
  });
  
  // Check if fix worked
  const employeesWithLeaves = Object.values(payrollStats).filter(emp => emp.leaveDays > 0);
  console.log(`📈 Summary: ${employeesWithLeaves.length} employees have leave days correctly calculated`);
  
  if (employeesWithLeaves.length > 0) {
    console.log('✅ PAYROLL FIX IS WORKING! Leave days are being properly integrated.');
  } else {
    console.log('❌ PAYROLL FIX NOT WORKING. Leave days are still 0.');
  }
}

testPayrollCalculation();
