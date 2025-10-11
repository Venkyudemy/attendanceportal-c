const express = require('express');
const router = express.Router();
const Employee = require('../models/Employee');
const LeaveRequest = require('../models/LeaveRequest');
const mongoose = require('mongoose');

// GET /api/employee/payroll/calculate-fixed - Fixed payroll calculation with proper leave integration
router.get('/calculate-fixed', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    // Determine payroll date range: 23rd of last month to 23rd of current month
    let payrollStartDate, payrollEndDate;
    
    if (startDate && endDate) {
      // Use provided dates if specified
      payrollStartDate = new Date(startDate);
      payrollEndDate = new Date(endDate);
    } else {
      // Calculate default payroll period
      const now = new Date();
      if (now.getDate() >= 23) {
        payrollStartDate = new Date(now.getFullYear(), now.getMonth(), 23);
        payrollEndDate = new Date(now.getFullYear(), now.getMonth() + 1, 23);
      } else {
        payrollStartDate = new Date(now.getFullYear(), now.getMonth() - 1, 23);
        payrollEndDate = new Date(now.getFullYear(), now.getMonth(), 23);
      }
    }

    console.log('📅 Calculating payroll for period:', payrollStartDate.toISOString(), 'to', payrollEndDate.toISOString());

    // Get all employees with their salary information
    const employees = await Employee.find({}).select('name email department salary monthlySalary attendance leaveBalance employeeId');
    
    // Get approved leave requests for the payroll period
    const leaveData = await LeaveRequest.find({
      startDate: { $lte: payrollEndDate },
      endDate: { $gte: payrollStartDate },
      status: 'Approved'
    });

    console.log('📋 Found', leaveData.length, 'approved leave requests for payroll period');
    console.log('👥 Found', employees.length, 'employees');

    const payrollStats = {};
    const fixedLatePenalty = 200; // ₹200 per late day
    const totalWorkingDays = 22; // Adjust per company policy

    // Initialize payroll stats for each employee
    employees.forEach(emp => {
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

    // Process attendance records for the payroll period
    employees.forEach(emp => {
      const empId = emp._id.toString();
      const attendanceRecords = emp.attendance.records || [];
      
      // Filter records for the payroll period
      const periodRecords = attendanceRecords.filter(record => {
        const recordDate = new Date(record.date);
        return recordDate >= payrollStartDate && recordDate < payrollEndDate;
      });

      // Count attendance days
      periodRecords.forEach(record => {
        if (record.status === 'Present' && !record.isLate) {
          payrollStats[empId].fullDays++;
        } else if (record.isLate) {
          payrollStats[empId].lateDays++;
        }
      });
    });

    // Process leave data for the payroll period - FIXED VERSION
    console.log('📋 Processing leave data for payroll integration...');
    
    leaveData.forEach(leave => {
      console.log('🔍 Processing leave request:', {
        leaveId: leave._id,
        employeeId: leave.employeeId,
        employeeName: leave.employeeName,
        employeeEmail: leave.employeeEmail,
        startDate: leave.startDate,
        endDate: leave.endDate,
        status: leave.status
      });
      
      // Try multiple matching strategies for employeeId
      let emp = null;
      const leaveEmployeeId = leave.employeeId;
      
      // Strategy 1: Direct ObjectId match
      if (mongoose.Types.ObjectId.isValid(leaveEmployeeId)) {
        emp = employees.find(e => e._id.toString() === leaveEmployeeId.toString());
      }
      
      // Strategy 2: Employee ID string match
      if (!emp) {
        emp = employees.find(e => e.employeeId === leaveEmployeeId);
      }
      
      // Strategy 3: Email match (fallback)
      if (!emp) {
        emp = employees.find(e => e.email === leave.employeeEmail);
      }
      
      // Strategy 4: Name match (last resort)
      if (!emp) {
        emp = employees.find(e => e.name.toLowerCase() === leave.employeeName.toLowerCase());
      }
      
      if (emp) {
        const empIdKey = emp._id.toString();
        console.log(`✅ Found matching employee: ${emp.name} (${emp.email}) for leave request`);
        
        if (payrollStats[empIdKey]) {
          // Calculate leave days within the payroll period
          const leaveStart = new Date(Math.max(new Date(leave.startDate), payrollStartDate));
          const leaveEnd = new Date(Math.min(new Date(leave.endDate), payrollEndDate));
          const leaveDaysCount = Math.ceil((leaveEnd - leaveStart) / (1000 * 60 * 60 * 24)) + 1;
          
          console.log(`📅 Leave calculation: ${leaveDaysCount} days for ${emp.name}`);
          
          if (leaveDaysCount > 0) {
            payrollStats[empIdKey].leaveDays += leaveDaysCount;
            console.log(`✅ Added ${leaveDaysCount} leave days to ${emp.name}. Total leave days: ${payrollStats[empIdKey].leaveDays}`);
          }
        }
      } else {
        console.log(`❌ No matching employee found for leave request: ${leave.employeeName} (${leave.employeeEmail})`);
        console.log('Available employees:', employees.map(e => ({ id: e._id, name: e.name, email: e.email, employeeId: e.employeeId })));
      }
    });

    // Calculate absents and LOP for each employee
    Object.keys(payrollStats).forEach(empId => {
      const stats = payrollStats[empId];
      const perDaySalary = stats.monthlySalary / totalWorkingDays;
      const attendedDays = stats.fullDays + stats.lateDays + stats.leaveDays;
      
      // Calculate absent days
      stats.absents = Math.max(0, totalWorkingDays - attendedDays);
      
      // Calculate Loss of Pay (LOP)
      const latePenalty = stats.lateDays * fixedLatePenalty;
      const absentPenalty = stats.absents * perDaySalary;
      stats.lopAmount = latePenalty + absentPenalty;
      
      // Calculate final pay
      stats.finalPay = Math.max(0, stats.monthlySalary - stats.lopAmount);
      
      // Round amounts to 2 decimal places
      stats.lopAmount = Math.round(stats.lopAmount * 100) / 100;
      stats.finalPay = Math.round(stats.finalPay * 100) / 100;
    });

    console.log('✅ Payroll calculation completed for', Object.keys(payrollStats).length, 'employees');

    res.status(200).json({
      success: true,
      payrollPeriod: {
        startDate: payrollStartDate.toISOString(),
        endDate: payrollEndDate.toISOString()
      },
      totalWorkingDays: totalWorkingDays,
      fixedLatePenalty: fixedLatePenalty,
      leaveRequestsProcessed: leaveData.length,
      payrollData: Object.values(payrollStats)
    });

  } catch (error) {
    console.error('Error calculating payroll:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to calculate payroll',
      details: error.message
    });
  }
});

// GET /api/employee/payroll/export-fixed - Export payroll data to CSV with fixed leave integration
router.get('/export-fixed', async (req, res) => {
  try {
    const { startDate, endDate, format = 'csv' } = req.query;
    
    // Calculate payroll data directly instead of making HTTP request
    let payrollStartDate, payrollEndDate;
    
    if (startDate && endDate) {
      payrollStartDate = new Date(startDate);
      payrollEndDate = new Date(endDate);
    } else {
      const now = new Date();
      if (now.getDate() >= 23) {
        payrollStartDate = new Date(now.getFullYear(), now.getMonth(), 23);
        payrollEndDate = new Date(now.getFullYear(), now.getMonth() + 1, 23);
      } else {
        payrollStartDate = new Date(now.getFullYear(), now.getMonth() - 1, 23);
        payrollEndDate = new Date(now.getFullYear(), now.getMonth(), 23);
      }
    }

    // Get all employees with their salary information
    const employees = await Employee.find({}).select('name email department salary monthlySalary attendance leaveBalance employeeId');
    
    // Get approved leave requests for the payroll period
    const leaveData = await LeaveRequest.find({
      startDate: { $lte: payrollEndDate },
      endDate: { $gte: payrollStartDate },
      status: 'Approved'
    });

    const payrollStats = {};
    const fixedLatePenalty = 200; // ₹200 per late day
    const totalWorkingDays = 22; // Adjust per company policy

    // Initialize payroll stats for each employee
    employees.forEach(emp => {
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

    // Process attendance records for the payroll period
    employees.forEach(emp => {
      const empId = emp._id.toString();
      const attendanceRecords = emp.attendance.records || [];
      
      // Filter records for the payroll period
      const periodRecords = attendanceRecords.filter(record => {
        const recordDate = new Date(record.date);
        return recordDate >= payrollStartDate && recordDate < payrollEndDate;
      });

      // Count attendance days
      periodRecords.forEach(record => {
        if (record.status === 'Present' && !record.isLate) {
          payrollStats[empId].fullDays++;
        } else if (record.isLate) {
          payrollStats[empId].lateDays++;
        }
      });
    });

    // Process leave data for the payroll period - FIXED VERSION
    leaveData.forEach(leave => {
      // Try multiple matching strategies for employeeId
      let emp = null;
      const leaveEmployeeId = leave.employeeId;
      
      // Strategy 1: Direct ObjectId match
      if (mongoose.Types.ObjectId.isValid(leaveEmployeeId)) {
        emp = employees.find(e => e._id.toString() === leaveEmployeeId.toString());
      }
      
      // Strategy 2: Employee ID string match
      if (!emp) {
        emp = employees.find(e => e.employeeId === leaveEmployeeId);
      }
      
      // Strategy 3: Email match (fallback)
      if (!emp) {
        emp = employees.find(e => e.email === leave.employeeEmail);
      }
      
      // Strategy 4: Name match (last resort)
      if (!emp) {
        emp = employees.find(e => e.name.toLowerCase() === leave.employeeName.toLowerCase());
      }
      
      if (emp) {
        const empIdKey = emp._id.toString();
        
        if (payrollStats[empIdKey]) {
          // Calculate leave days within the payroll period
          const leaveStart = new Date(Math.max(new Date(leave.startDate), payrollStartDate));
          const leaveEnd = new Date(Math.min(new Date(leave.endDate), payrollEndDate));
          const leaveDaysCount = Math.ceil((leaveEnd - leaveStart) / (1000 * 60 * 60 * 24)) + 1;
          
          if (leaveDaysCount > 0) {
            payrollStats[empIdKey].leaveDays += leaveDaysCount;
          }
        }
      }
    });

    // Calculate absents and LOP for each employee
    Object.keys(payrollStats).forEach(empId => {
      const stats = payrollStats[empId];
      const perDaySalary = stats.monthlySalary / totalWorkingDays;
      const attendedDays = stats.fullDays + stats.lateDays + stats.leaveDays;
      
      // Calculate absent days
      stats.absents = Math.max(0, totalWorkingDays - attendedDays);
      
      // Calculate Loss of Pay (LOP)
      const latePenalty = stats.lateDays * fixedLatePenalty;
      const absentPenalty = stats.absents * perDaySalary;
      stats.lopAmount = latePenalty + absentPenalty;
      
      // Calculate final pay
      stats.finalPay = Math.max(0, stats.monthlySalary - stats.lopAmount);
      
      // Round amounts to 2 decimal places
      stats.lopAmount = Math.round(stats.lopAmount * 100) / 100;
      stats.finalPay = Math.round(stats.finalPay * 100) / 100;
    });

    const payrollData = Object.values(payrollStats);
    
    if (format === 'csv') {
      // Convert to CSV format
      const csvHeaders = [
        'Employee Name', 'Email', 'Department', 'Monthly Salary',
        'Full Days', 'Late Days', 'Absent Days', 'Leave Days',
        'LOP Amount', 'Final Pay'
      ];
      
      const csvRows = payrollData.map(emp => [
        emp.name,
        emp.email,
        emp.department,
        emp.monthlySalary,
        emp.fullDays,
        emp.lateDays,
        emp.absents,
        emp.leaveDays,
        emp.lopAmount,
        emp.finalPay
      ]);
      
      const csvContent = [
        csvHeaders.join(','),
        ...csvRows.map(row => row.map(field => `"${field}"`).join(','))
      ].join('\n');
      
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename="payroll-${new Date().toISOString().split('T')[0]}.csv"`);
      res.send(csvContent);
    } else {
      res.json({
        success: true,
        payrollPeriod: {
          startDate: payrollStartDate.toISOString(),
          endDate: payrollEndDate.toISOString()
        },
        totalWorkingDays: totalWorkingDays,
        fixedLatePenalty: fixedLatePenalty,
        leaveRequestsProcessed: leaveData.length,
        payrollData: payrollData
      });
    }

  } catch (error) {
    console.error('Error exporting payroll data:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to export payroll data',
      details: error.message
    });
  }
});

module.exports = router;
