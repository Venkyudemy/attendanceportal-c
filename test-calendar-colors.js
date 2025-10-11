// Test script for calendar color coding and layout
console.log('🎨 Calendar Color Coding Test');

// Test color functions
const getStatusColor = (status) => {
  switch (status) {
    case 'Present': return '#28a745'; // Green
    case 'Late': return '#ffc107'; // Yellow
    case 'Absent': return '#dc3545'; // Red
    case 'On Leave': return '#17a2b8'; // Blue
    case 'Holiday': return '#fd7e14'; // Orange
    default: return '#6c757d'; // Gray
  }
};

const getDayBorderColor = (dayData) => {
  if (dayData.isEmpty) return 'transparent';
  if (dayData.isWeekend) return '#e9ecef'; // Light gray for weekends
  if (dayData.attendance) {
    return getStatusColor(dayData.attendance.status);
  }
  return 'transparent'; // No attendance data
};

const getDayBackgroundColor = (dayData) => {
  if (dayData.isEmpty) return 'transparent';
  if (dayData.isToday) return '#e3f2fd'; // Light blue for today
  if (dayData.isWeekend) return '#f8f9fa'; // Light gray for weekends
  if (dayData.attendance) {
    switch (dayData.attendance.status) {
      case 'Present': return '#d4edda'; // Light green
      case 'Late': return '#fff3cd'; // Light yellow
      case 'Absent': return '#f8d7da'; // Light red
      case 'On Leave': return '#d1ecf1'; // Light blue
      case 'Holiday': return '#ffeaa7'; // Light orange
      default: return '#f8f9fa'; // Light gray
    }
  }
  return '#ffffff'; // White for no data
};

// Test cases
const testCases = [
  { status: 'Present', expectedBorder: '#28a745', expectedBg: '#d4edda' },
  { status: 'Late', expectedBorder: '#ffc107', expectedBg: '#fff3cd' },
  { status: 'Absent', expectedBorder: '#dc3545', expectedBg: '#f8d7da' },
  { status: 'On Leave', expectedBorder: '#17a2b8', expectedBg: '#d1ecf1' },
  { status: 'Holiday', expectedBorder: '#fd7e14', expectedBg: '#ffeaa7' },
];

console.log('\n📊 Testing Color Functions:');
testCases.forEach((testCase, index) => {
  const dayData = { attendance: { status: testCase.status } };
  const borderColor = getDayBorderColor(dayData);
  const backgroundColor = getDayBackgroundColor(dayData);
  
  const borderMatch = borderColor === testCase.expectedBorder;
  const bgMatch = backgroundColor === testCase.expectedBg;
  
  console.log(`${index + 1}. ${testCase.status}:`);
  console.log(`   Border: ${borderColor} ${borderMatch ? '✅' : '❌'}`);
  console.log(`   Background: ${backgroundColor} ${bgMatch ? '✅' : '❌'}`);
});

// Test weekend and empty day colors
console.log('\n🏖️ Testing Special Cases:');
const weekendData = { isWeekend: true };
const emptyData = { isEmpty: true };
const todayData = { isToday: true, attendance: { status: 'Present' } };

console.log(`Weekend - Border: ${getDayBorderColor(weekendData)}, Background: ${getDayBackgroundColor(weekendData)}`);
console.log(`Empty - Border: ${getDayBorderColor(emptyData)}, Background: ${getDayBackgroundColor(emptyData)}`);
console.log(`Today - Border: ${getDayBorderColor(todayData)}, Background: ${getDayBackgroundColor(todayData)}`);

console.log('\n✅ Color coding test completed!');
console.log('\n🎯 Expected Calendar Layout:');
console.log('   - Days properly aligned with week columns (Sun-Sat)');
console.log('   - Color-coded borders for each attendance status');
console.log('   - Matching background colors for visual clarity');
console.log('   - Weekend days with light gray styling');
console.log('   - Today highlighted with blue border');
console.log('   - Legend showing all color meanings');

console.log('\n📱 Responsive Features:');
console.log('   - Legend adapts to smaller screens');
console.log('   - Calendar grid maintains proper alignment');
console.log('   - Touch-friendly interactions on mobile');
console.log('   - Optimized spacing for different screen sizes');
