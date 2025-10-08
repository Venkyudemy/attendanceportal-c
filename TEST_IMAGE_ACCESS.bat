@echo off
echo ========================================
echo 🔍 TESTING IMAGE ACCESS
echo ========================================
echo Testing if the specific image from your screenshot is accessible...

echo.
echo 📋 Step 1: Starting backend...
docker compose up -d backend
timeout /t 15 /nobreak

echo.
echo 📋 Step 2: Testing the specific image file from your screenshot...
docker compose exec backend node -e "
const fs = require('fs');
const path = require('path');

console.log('🔍 TESTING SPECIFIC IMAGE FROM YOUR SCREENSHOT...');

// From your screenshot: employee ID 68e4bfe05183cffc04319bf8
// Image: checkin_2025-10-08_19-43-06.jpg
const empId = '68e4bfe05183cffc04319bf8';
const imageFile = 'checkin_2025-10-08_19-43-06.jpg';
const imagePath = '/uploads/employees/' + empId + '/' + imageFile;
const fullPath = '/app' + imagePath;

console.log('Employee ID:', empId);
console.log('Image file:', imageFile);
console.log('Relative path:', imagePath);
console.log('Full path:', fullPath);
console.log('File exists:', fs.existsSync(fullPath));

if (fs.existsSync(fullPath)) {
  const stats = fs.statSync(fullPath);
  console.log('✅ FILE EXISTS!');
  console.log('File size:', stats.size, 'bytes');
  console.log('File modified:', stats.mtime);
  console.log('File permissions:', stats.mode);
  
  // Test if file is readable
  try {
    const buffer = fs.readFileSync(fullPath);
    console.log('✅ FILE IS READABLE!');
    console.log('First few bytes:', buffer.slice(0, 10).toString('hex'));
    
    // Check if it's a valid JPG file
    if (buffer[0] === 0xFF && buffer[1] === 0xD8) {
      console.log('✅ VALID JPG FILE!');
    } else {
      console.log('❌ NOT A VALID JPG FILE!');
    }
  } catch (err) {
    console.log('❌ FILE READ ERROR:', err.message);
  }
} else {
  console.log('❌ FILE DOES NOT EXIST!');
  console.log('Checking parent directory...');
  const parentDir = path.dirname(fullPath);
  console.log('Parent directory:', parentDir);
  console.log('Parent exists:', fs.existsSync(parentDir));
  
  if (fs.existsSync(parentDir)) {
    const files = fs.readdirSync(parentDir);
    console.log('Files in parent directory:', files);
  }
}

process.exit(0);
"

echo.
echo 📋 Step 3: Testing HTTP access to the image...
echo Testing if the image can be accessed via HTTP...

docker compose exec backend curl -I http://localhost:5000/uploads/employees/68e4bfe05183cffc04319bf8/checkin_2025-10-08_19-43-06.jpg 2>nul

echo.
echo 📋 Step 4: Testing from frontend perspective...
echo Testing if the image URL works from frontend...

docker compose exec backend curl -s -o /dev/null -w "HTTP Status: %{http_code}\nContent-Type: %{content_type}\nSize: %{size_download} bytes\n" http://localhost:5000/uploads/employees/68e4bfe05183cffc04319bf8/checkin_2025-10-08_19-43-06.jpg

echo.
echo ========================================
echo 🔍 IMAGE ACCESS TEST COMPLETE!
echo ========================================
echo.
echo 💡 Results above will show:
echo 1. Does the image file exist on disk?
echo 2. Is the file readable and valid?
echo 3. Can the backend serve it via HTTP?
echo 4. What's the HTTP response when accessing the image?
echo.
echo 🧪 If the image exists and is accessible:
echo - The issue is in the frontend image loading
echo - Run FRONTEND_IMAGE_DISPLAY_FIX.bat
echo.
echo 🧪 If the image doesn't exist or isn't accessible:
echo - The issue is in the backend image saving
echo - Check backend logs for upload errors
echo.
pause
