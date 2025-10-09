const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Base uploads directory
const baseUploadsDir = path.join(__dirname, '..', 'uploads', 'employees');

// Create base uploads directory if it doesn't exist
if (!fs.existsSync(baseUploadsDir)) {
  fs.mkdirSync(baseUploadsDir, { recursive: true });
  console.log('✅ Created base uploads directory:', baseUploadsDir);
}

// Configure multer storage with employee-specific folders
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // Create employee-specific folder
    const employeeId = req.params.id || 'unknown';
    const employeeDir = path.join(baseUploadsDir, employeeId);
    
    // Create directory if it doesn't exist
    if (!fs.existsSync(employeeDir)) {
      fs.mkdirSync(employeeDir, { recursive: true });
      console.log(`✅ Created employee folder: ${employeeDir}`);
    }
    
    cb(null, employeeDir);
  },
  filename: function (req, file, cb) {
    // Create filename with date and type: checkin_2024-01-15_timestamp.jpg
    const now = new Date();
    const dateStr = now.toISOString().split('T')[0]; // YYYY-MM-DD
    const timeStr = now.toTimeString().split(' ')[0].replace(/:/g, '-'); // HH-MM-SS
    const type = req.body.type || 'checkin'; // 'checkin' or 'checkout'
    const filename = `${type}_${dateStr}_${timeStr}.jpg`;
    
    console.log(`📸 Saving image: ${filename}`);
    cb(null, filename);
  }
});

// File filter to accept only images
const fileFilter = (req, file, cb) => {
  // Accept only image files
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed!'), false);
  }
};

// Configure multer upload
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  }
});

module.exports = upload;

