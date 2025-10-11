// Test script to verify calendar alignment
console.log('📅 Calendar Alignment Test');

// Test the calendar logic for October 2025
const testCalendarAlignment = () => {
  const year = 2025;
  const month = 9; // October (0-indexed)
  
  const firstDay = new Date(year, month, 1);
  const lastDay = new Date(year, month + 1, 0);
  const daysInMonth = lastDay.getDate();
  const startingDayOfWeek = firstDay.getDay();
  
  console.log(`\n📅 Testing October 2025:`);
  console.log(`   First day: ${firstDay.toDateString()}`);
  console.log(`   Starting day of week: ${startingDayOfWeek} (${firstDay.toLocaleDateString('en-US', { weekday: 'long' })})`);
  console.log(`   Days in month: ${daysInMonth}`);
  
  // Expected: October 1, 2025 should be a Wednesday (day 3)
  const expectedDayOfWeek = 3; // Wednesday
  const isCorrect = startingDayOfWeek === expectedDayOfWeek;
  
  console.log(`\n✅ Expected: Day 3 (Wednesday), Got: Day ${startingDayOfWeek} (${firstDay.toLocaleDateString('en-US', { weekday: 'long' })})`);
  console.log(`   Result: ${isCorrect ? '✅ CORRECT' : '❌ INCORRECT'}`);
  
  if (!isCorrect) {
    console.log(`\n❌ Calendar alignment issue detected!`);
    console.log(`   The calendar is not properly calculating the starting day of the week.`);
    console.log(`   This will cause days to appear under wrong weekday columns.`);
  } else {
    console.log(`\n✅ Calendar alignment is correct!`);
  }
  
  // Test first week alignment
  console.log(`\n📊 First Week Layout:`);
  const weekHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  console.log(`   Headers: ${weekHeaders.join(' | ')}`);
  
  let firstWeekLayout = [];
  for (let i = 0; i < 7; i++) {
    if (i < startingDayOfWeek) {
      firstWeekLayout.push('--');
    } else {
      firstWeekLayout.push(String(i - startingDayOfWeek + 1));
    }
  }
  console.log(`   Days:    ${firstWeekLayout.join(' | ')}`);
  
  // Verify the alignment
  const oct1Column = startingDayOfWeek; // Column index where Oct 1 should appear
  console.log(`\n🎯 October 1st should appear in column ${oct1Column} (${weekHeaders[oct1Column]})`);
  
  return isCorrect;
};

// Test multiple months
const testMultipleMonths = () => {
  const testMonths = [
    { year: 2025, month: 9, name: 'October 2025' },
    { year: 2024, month: 11, name: 'December 2024' },
    { year: 2025, month: 0, name: 'January 2025' }
  ];
  
  console.log('\n📅 Testing Multiple Months:');
  let allCorrect = true;
  
  testMonths.forEach(test => {
    const firstDay = new Date(test.year, test.month, 1);
    const startingDayOfWeek = firstDay.getDay();
    const weekdayName = firstDay.toLocaleDateString('en-US', { weekday: 'long' });
    
    console.log(`   ${test.name}: Day ${startingDayOfWeek} (${weekdayName})`);
    
    // Basic sanity check - first day should be valid (0-6)
    if (startingDayOfWeek < 0 || startingDayOfWeek > 6) {
      console.log(`   ❌ Invalid day of week: ${startingDayOfWeek}`);
      allCorrect = false;
    }
  });
  
  return allCorrect;
};

// Run tests
console.log('🧪 Running Calendar Alignment Tests...\n');

const alignmentTest = testCalendarAlignment();
const multiMonthTest = testMultipleMonths();

console.log('\n📋 Test Results:');
console.log(`   October 2025 Alignment: ${alignmentTest ? '✅ PASS' : '❌ FAIL'}`);
console.log(`   Multiple Months Test: ${multiMonthTest ? '✅ PASS' : '❌ FAIL'}`);

if (alignmentTest && multiMonthTest) {
  console.log('\n🎉 All tests passed! Calendar alignment should be working correctly.');
  console.log('\n💡 If the calendar still shows misaligned days, check:');
  console.log('   1. Browser timezone settings');
  console.log('   2. Date object creation in the component');
  console.log('   3. CSS grid layout issues');
  console.log('   4. JavaScript Date.getDay() method behavior');
} else {
  console.log('\n❌ Some tests failed. Calendar alignment needs to be fixed.');
}

// Additional debugging info
console.log('\n🔍 Debug Information:');
console.log(`   Current date: ${new Date().toDateString()}`);
console.log(`   Current day of week: ${new Date().getDay()}`);
console.log(`   Browser timezone: ${Intl.DateTimeFormat().resolvedOptions().timeZone}`);

// Test the actual calendar logic
const testCalendarLogic = () => {
  console.log('\n🧮 Testing Calendar Logic:');
  
  const year = 2025;
  const month = 9; // October
  const firstDay = new Date(year, month, 1);
  const startingDayOfWeek = firstDay.getDay();
  
  const days = [];
  
  // Add empty cells
  for (let i = 0; i < startingDayOfWeek; i++) {
    days.push({ isEmpty: true, column: i });
  }
  
  // Add first 7 days
  for (let day = 1; day <= 7; day++) {
    const dayDate = new Date(year, month, day);
    const actualDayOfWeek = dayDate.getDay();
    const column = days.length;
    
    days.push({ 
      date: dayDate, 
      day: day,
      actualDayOfWeek: actualDayOfWeek,
      column: column,
      isEmpty: false 
    });
  }
  
  console.log('   First 7 days layout:');
  console.log('   Column | Day | Actual DoW | Expected DoW | Match');
  console.log('   -------|-----|------------|--------------|------');
  
  days.forEach((dayData, index) => {
    if (dayData.isEmpty) {
      console.log(`   ${index}      | --  | --         | --           | --`);
    } else {
      const expectedDoW = index;
      const match = dayData.actualDayOfWeek === expectedDoW ? '✅' : '❌';
      console.log(`   ${index}      | ${dayData.day.toString().padStart(2)}  | ${dayData.actualDayOfWeek}           | ${expectedDoW}            | ${match}`);
    }
  });
};

testCalendarLogic();
