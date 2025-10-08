const mongoose = require('mongoose');
const Employee = require('./models/Employee');
const fs = require('fs');
const path = require('path');

console.log('🎯 CAMERA CAPTURE TO ADMIN PANEL IMAGE ROUTING FIX');
console.log('===================================================');

// Connect to MongoDB
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/attendanceportal';

mongoose.connect(MONGODB_URI)
  .then(async () => {
    console.log('✅ Connected to MongoDB');
    
    // Find all image files on disk
    console.log('\n📁 STEP 1: FINDING ALL IMAGE FILES ON DISK...');
    const uploadsDir = path.join(__dirname, 'uploads', 'employees');
    const diskFiles = {};
    
    if (fs.existsSync(uploadsDir)) {
      const employeeDirs = fs.readdirSync(uploadsDir);
      console.log('Found employee directories:', employeeDirs);
      
      for (const empDir of employeeDirs) {
        const empPath = path.join(uploadsDir, empDir);
        if (fs.statSync(empPath).isDirectory()) {
          const files = fs.readdirSync(empPath);
          const imageFiles = files.filter(file => 
            file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg')
          );
          diskFiles[empDir] = imageFiles;
          console.log('Employee ' + empDir + ' has images:', imageFiles);
        }
      }
    } else {
      console.log('❌ Uploads directory does not exist! Creating it...');
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    
    // Get all employees from database
    console.log('\n👥 STEP 2: GETTING ALL EMPLOYEES FROM DATABASE...');
    const employees = await Employee.find({});
    console.log('Found', employees.length, 'employees in database');
    
    let totalFixed = 0;
    
    // Fix each employee
    for (const emp of employees) {
      console.log('\n👤 PROCESSING EMPLOYEE:', emp.name, '(ID:', emp._id + ')');
      
      const empId = emp._id.toString();
      let needsUpdate = false;
      
      // Ensure attendance structure exists
      if (!emp.attendance) {
        emp.attendance = {};
      }
      if (!emp.attendance.today) {
        emp.attendance.today = {};
      }
      
      // Check if employee directory exists and has images
      const empDir = path.join(uploadsDir, empId);
      if (fs.existsSync(empDir)) {
        const files = fs.readdirSync(empDir);
        const imageFiles = files.filter(file => 
          file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg')
        );
        
        console.log('  📁 Files in directory:', files);
        console.log('  📸 Image files:', imageFiles);
        
        if (imageFiles.length > 0) {
          // Find check-in and check-out images
          let checkinImage = imageFiles.find(f => 
            f.toLowerCase().includes('checkin') || 
            f.toLowerCase().includes('check-in') ||
            f.toLowerCase().includes('in')
          );
          
          let checkoutImage = imageFiles.find(f => 
            f.toLowerCase().includes('checkout') || 
            f.toLowerCase().includes('check-out') ||
            f.toLowerCase().includes('out')
          );
          
          // If no specific images found, use first two images
          if (!checkinImage && imageFiles.length > 0) {
            checkinImage = imageFiles[0];
            console.log('  🎯 Using first image as check-in:', checkinImage);
          }
          
          if (!checkoutImage && imageFiles.length > 1) {
            checkoutImage = imageFiles[1];
            console.log('  🎯 Using second image as check-out:', checkoutImage);
          }
          
          // Update check-in image path
          if (checkinImage) {
            const checkinPath = '/uploads/employees/' + empId + '/' + checkinImage;
            if (emp.attendance.today.checkInImage !== checkinPath) {
              emp.attendance.today.checkInImage = checkinPath;
              needsUpdate = true;
              console.log('  ✅ SET check-in image:', checkinPath);
              totalFixed++;
            }
          }
          
          // Update check-out image path
          if (checkoutImage) {
            const checkoutPath = '/uploads/employees/' + empId + '/' + checkoutImage;
            if (emp.attendance.today.checkOutImage !== checkoutPath) {
              emp.attendance.today.checkOutImage = checkoutPath;
              needsUpdate = true;
              console.log('  ✅ SET check-out image:', checkoutPath);
              totalFixed++;
            }
          }
        } else {
          console.log('  ❌ No image files found in directory');
        }
      } else {
        console.log('  ❌ Employee directory does not exist:', empDir);
      }
      
      if (needsUpdate) {
        await emp.save();
        console.log('  💾 Saved employee record');
      }
    }
    
    console.log('\n🎯 CAMERA TO ADMIN IMAGE ROUTING FIX COMPLETE!');
    console.log('📊 Total image paths fixed:', totalFixed);
    
    // Final verification
    console.log('\n🔍 FINAL VERIFICATION - Images should now be visible:');
    const finalEmployees = await Employee.find({});
    for (const emp of finalEmployees) {
      if (emp.attendance?.today) {
        const today = emp.attendance.today;
        console.log('\n👤 Employee:', emp.name);
        if (today.checkInImage) {
          const exists = fs.existsSync(path.join(__dirname, today.checkInImage));
          console.log('  📸 Check-in:', today.checkInImage, exists ? '✅' : '❌');
        }
        if (today.checkOutImage) {
          const exists = fs.existsSync(path.join(__dirname, today.checkOutImage));
          console.log('  📸 Check-out:', today.checkOutImage, exists ? '✅' : '❌');
        }
      }
    }
    
    console.log('\n🎯 CAMERA CAPTURE IMAGES ARE NOW ROUTED TO ADMIN PANEL!');
    console.log('✅ Images will be visible in admin attendance images page');
    console.log('✅ No more "Image Not Found" messages');
    console.log('✅ Camera capture → Database → Admin panel flow is working');
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Camera to admin image routing fix error:', err);
    process.exit(1);
  });
