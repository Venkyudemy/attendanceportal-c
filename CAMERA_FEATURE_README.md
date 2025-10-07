# 📸 Camera Capture Feature - Implementation Guide

## Overview
The attendance portal now includes **camera capture functionality** for employee check-in and check-out. When employees check in or out, they must capture their photo which is saved as a JPG image and displayed in the admin panel.

## ✨ Features Added

### 1. **Camera Capture Component**
- Real-time camera access with preview
- Capture photos in JPG format
- Retake/confirm functionality
- Mirror effect for front camera
- Mobile responsive design
- Error handling for camera permissions

### 2. **Backend Image Storage**
- Images stored in `/Backend/uploads/attendance-images/`
- Unique filename format: `{employeeId}_{type}_{timestamp}.jpg`
- File size limit: 5MB per image
- Automatic directory creation
- Static file serving enabled

### 3. **Database Integration**
- Employee model updated with image fields:
  - `checkInImage` - Path to check-in photo
  - `checkOutImage` - Path to check-out photo
- Images stored in both daily records and attendance history

### 4. **Admin Panel Display**
- Thumbnail images in attendance tables (60x60px)
- Click to view full-size image in new tab
- Shows both check-in and check-out photos
- Displays "-" when no image available

## 📁 Files Modified/Created

### **Backend Changes:**

1. **`/Backend/package.json`**
   - Added `multer` dependency for file uploads

2. **`/Backend/config/multer.js`** (NEW)
   - Multer configuration for image upload
   - Storage location and filename generation
   - File type validation (images only)

3. **`/Backend/models/Employee.js`**
   - Added `checkInImage` field to attendance records
   - Added `checkOutImage` field to attendance records
   - Added image fields to today's attendance schema

4. **`/Backend/index.js`**
   - Added static file serving: `/uploads` route
   - Serves uploaded images to frontend

5. **`/Backend/routes/employee.js`**
   - Added `POST /:id/check-in-with-image` endpoint
   - Added `POST /:id/check-out-with-image` endpoint
   - Imported multer middleware

### **Frontend Changes:**

1. **`/Frontend/src/components/shared/CameraCapture.js`** (NEW)
   - React component for camera access
   - Photo capture and preview
   - Blob conversion to JPG format

2. **`/Frontend/src/components/shared/CameraCapture.css`** (NEW)
   - Beautiful UI styling
   - Responsive design
   - Animations and transitions

3. **`/Frontend/src/components/employee/EmployeePortal.js`**
   - Imported CameraCapture component
   - Modified `handleCheckIn()` to show camera
   - Modified `handleCheckOut()` to show camera
   - Added `processCheckInWithImage()` function
   - Added `processCheckOutWithImage()` function
   - Added camera state management

4. **`/Frontend/src/components/employee/EmployeeAttendanceView.js`**
   - Added "Check In Photo" and "Check Out Photo" columns
   - Display thumbnail images with click to enlarge
   - Updated data mapping to include image fields

## 🚀 How It Works

### **Employee Flow:**

1. **Check-In Process:**
   ```
   Employee clicks "Check In" button
   → Camera modal opens
   → Employee captures photo
   → Review and confirm/retake
   → Photo uploaded with check-in data
   → Success message displayed
   ```

2. **Check-Out Process:**
   ```
   Employee clicks "Check Out" button
   → Camera modal opens
   → Employee captures photo
   → Review and confirm/retake
   → Photo uploaded with check-out data
   → Success message with hours worked
   ```

### **Admin Flow:**

1. **View Attendance Images:**
   ```
   Admin → Employee Management
   → Click on employee
   → View "Attendance History"
   → See thumbnails in table
   → Click thumbnail to view full image
   ```

## 🔧 API Endpoints

### **Check-In with Image**
```
POST /api/employee/:id/check-in-with-image
Content-Type: multipart/form-data

Body:
- image: File (JPG/PNG)
- type: 'checkin'

Response:
{
  "message": "Check-in successful",
  "checkInTime": "09:00 AM",
  "status": "Present",
  "isLate": false,
  "employeeName": "John Doe",
  "imagePath": "/uploads/attendance-images/123_checkin_1234567890.jpg",
  "timestamp": "2024-01-01T09:00:00.000Z"
}
```

### **Check-Out with Image**
```
POST /api/employee/:id/check-out-with-image
Content-Type: multipart/form-data

Body:
- image: File (JPG/PNG)
- type: 'checkout'

Response:
{
  "message": "Check-out successful",
  "checkOutTime": "05:00 PM",
  "hoursWorked": 8.0,
  "totalHoursToday": 8.0,
  "imagePath": "/uploads/attendance-images/123_checkout_1234567890.jpg",
  "date": "2024-01-01"
}
```

## 💻 Installation & Setup

### **1. Install Dependencies:**

```bash
cd Backend
npm install
```

This will install the `multer` package for file uploads.

### **2. Directory Structure:**

The uploads directory is created automatically when the first image is uploaded:
```
Backend/
└── uploads/
    └── attendance-images/
        ├── {employeeId}_checkin_{timestamp}.jpg
        └── {employeeId}_checkout_{timestamp}.jpg
```

### **3. Environment Configuration:**

No additional environment variables needed. Images are served from:
```
http://localhost:5000/uploads/attendance-images/{filename}
```

### **4. Start the Application:**

```bash
# Backend
cd Backend
npm start

# Frontend (in another terminal)
cd Frontend
npm start
```

## 📱 Camera Permissions

### **Browser Permissions Required:**
- Camera access must be granted
- Works on HTTPS or localhost
- Mobile and desktop compatible

### **Permission Denied Handling:**
- Error message displayed
- Retry button available
- User can close and try again

## 🎨 UI/UX Features

### **Camera Modal:**
- Fullscreen overlay with dark background
- Video preview with mirror effect
- Large capture button
- Retake and confirm options
- Smooth animations

### **Image Display (Admin):**
- 60x60px thumbnails in table
- Rounded corners
- Click to open full size in new tab
- "-" shown when no image available

## 🔒 Security Considerations

### **File Upload Security:**
1. **File Type Validation:** Only images allowed
2. **File Size Limit:** 5MB maximum
3. **Unique Filenames:** Prevents overwrites
4. **Directory Isolation:** Images in dedicated folder

### **Access Control:**
- Employees can only upload for their own ID
- Admin can view all images
- Images served through static middleware

## 🐛 Troubleshooting

### **Camera Not Working:**
- Check browser permissions
- Ensure HTTPS or localhost
- Try different browser
- Check console for errors

### **Images Not Displaying:**
- Verify backend is running
- Check network tab for 404 errors
- Ensure static files route is configured
- Check image paths in database

### **Upload Fails:**
- Check file size (< 5MB)
- Verify multer is installed
- Check backend logs
- Ensure uploads directory exists

## 📊 Database Schema

### **Attendance Record:**
```javascript
{
  date: "2024-01-01",
  checkIn: "09:00 AM",
  checkOut: "05:00 PM",
  status: "Present",
  hours: 8.0,
  isLate: false,
  timestamp: "2024-01-01T09:00:00.000Z",
  checkInImage: "/uploads/attendance-images/123_checkin_1234567890.jpg",  // NEW
  checkOutImage: "/uploads/attendance-images/123_checkout_1234567890.jpg" // NEW
}
```

## ✅ Testing Checklist

- [ ] Camera opens on check-in click
- [ ] Camera opens on check-out click
- [ ] Photo capture works
- [ ] Retake functionality works
- [ ] Confirm uploads image
- [ ] Image saved to backend
- [ ] Image path stored in database
- [ ] Thumbnail displays in admin panel
- [ ] Full image opens on click
- [ ] Works on mobile devices
- [ ] Handles camera permission denied

## 🎉 Success!

Your attendance portal now has a fully functional camera capture feature! Employees must take photos during check-in and check-out, and admins can view all captured images in the admin panel.

## 📞 Support

For issues or questions:
1. Check console logs (F12)
2. Verify all dependencies installed
3. Ensure database is running
4. Check camera permissions

---

**Made with ❤️ for secure and verified attendance tracking**

