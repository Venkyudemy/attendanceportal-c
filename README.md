# 📸 Attendance Portal with Camera Feature

A comprehensive attendance management system with **camera capture functionality** for employee check-in and check-out verification.

## 🎯 **Features**

### **Core Functionality**
- ✅ **Employee Management** - Add, edit, delete employees
- ✅ **Attendance Tracking** - Check-in/check-out with timestamps
- ✅ **Leave Management** - Request and approve leaves
- ✅ **Payroll Integration** - Automatic salary calculations
- ✅ **Admin Dashboard** - Comprehensive analytics and reports

### **📸 Camera Feature (NEW!)**
- ✅ **Camera Capture** - Automatic camera opening on check-in/check-out
- ✅ **Image Storage** - JPG format with 5MB limit
- ✅ **Database Integration** - Image paths stored in MongoDB
- ✅ **Admin Viewer** - Dedicated page to view all attendance photos
- ✅ **Employee Folders** - Organized storage by employee ID
- ✅ **Docker Support** - Persistent volume storage

## 🚀 **Quick Start**

### **Prerequisites**
- Node.js (v14+)
- MongoDB
- Docker (optional)

### **Local Development**

1. **Clone the repository**
   ```bash
   git clone https://github.com/Venkyudemy/attendanceportal-c.git
   cd attendanceportal-c
   ```

2. **Start Backend**
   ```bash
   cd Backend
   npm install
   npm start
   ```

3. **Start Frontend**
   ```bash
   cd Frontend
   npm install
   npm start
   ```

4. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000

### **Docker Deployment**

```bash
# Development
docker-compose up --build -d

# Production
docker-compose -f docker-compose.prod.yml up --build -d
```

## 📱 **How It Works**

### **Employee Check-in/Check-out with Camera**
1. Employee clicks "Check In" or "Check Out"
2. Camera automatically opens
3. Live preview shows employee
4. Click "Capture Photo" to take picture
5. Confirm or retake photo
6. Photo saved to server and database
7. Attendance recorded with timestamp

### **Admin Photo Management**
1. Login as admin
2. Navigate to "📸 Attendance Images"
3. View all employee photos in table format
4. Filter by date
5. Click photos to view full-size
6. Green border = Check-in photos
7. Red border = Check-out photos

## 🏗️ **Architecture**

```
Frontend (React.js)
├── CameraCapture component
├── EmployeePortal with camera integration
├── AttendanceImages admin panel
└── Responsive UI

Backend (Node.js + Express)
├── Multer file upload middleware
├── MongoDB with image paths
├── Employee-specific folder structure
└── RESTful APIs

Database (MongoDB)
├── Employee collection with attendance
├── Image paths in attendance records
└── Persistent image metadata

Storage
├── /uploads/employees/{employeeId}/
├── checkin_YYYY-MM-DD_HH-MM-SS.jpg
└── checkout_YYYY-MM-DD_HH-MM-SS.jpg
```

## 📊 **API Endpoints**

### **Camera & Images**
- `POST /api/employee/:id/check-in-with-image` - Upload check-in photo
- `POST /api/employee/:id/check-out-with-image` - Upload check-out photo
- `GET /api/employee/attendance` - Get attendance with image paths
- `GET /uploads/employees/:id/:filename` - Serve image files

### **Core APIs**
- `POST /api/auth/login` - User authentication
- `GET /api/employee/details/:id` - Employee details
- `POST /api/employee/:id/check-in` - Regular check-in
- `POST /api/employee/:id/check-out` - Regular check-out

## 🐳 **Docker Configuration**

### **Updated Docker Compose Files**
- ✅ `docker-compose.yml` - Development with camera support
- ✅ `docker-compose.prod.yml` - Production with persistent volumes
- ✅ `docker-compose.external.yml` - External deployment

### **Key Docker Features**
- **Persistent Image Storage** - `uploads_data` volume
- **File Upload Limits** - 5MB maximum
- **Proper Permissions** - 755 for upload directories
- **Multi-environment Support** - Dev, prod, external configs

## 📁 **File Structure**

```
attendanceportal-c/
├── Backend/
│   ├── config/multer.js          # Image upload configuration
│   ├── models/Employee.js        # Database schema with image fields
│   ├── routes/employee.js        # Camera API endpoints
│   ├── uploads/employees/        # Image storage (Docker volume)
│   └── verify-database-images.js # Database verification script
├── Frontend/
│   ├── src/components/
│   │   ├── shared/CameraCapture.js    # Camera component
│   │   ├── admin/AttendanceImages.js  # Admin photo viewer
│   │   └── employee/EmployeePortal.js # Employee interface
│   └── src/App.js               # Updated with camera routes
├── docker-compose.yml           # Updated with camera support
└── README.md                   # This file
```

## 🔧 **Configuration**

### **Environment Variables**
```bash
# Backend
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb://localhost:27017/attendanceportal
MAX_FILE_SIZE=5242880
UPLOAD_PATH=/app/uploads

# Frontend
REACT_APP_API_URL=http://localhost:5000/api
```

### **MongoDB Schema**
```javascript
{
  name: "Employee Name",
  email: "employee@company.com",
  attendance: {
    today: {
      date: "2025-10-06",
      checkIn: "09:00 AM",
      checkInImage: "/uploads/employees/123/checkin_2025-10-06_09-00-00.jpg",
      checkOut: "05:00 PM",
      checkOutImage: "/uploads/employees/123/checkout_2025-10-06_17-00-00.jpg",
      status: "Present",
      hours: 8.0
    },
    records: [
      {
        date: "2025-10-06",
        checkIn: "09:00 AM",
        checkInImage: "/uploads/employees/123/checkin_2025-10-06_09-00-00.jpg",
        checkOut: "05:00 PM", 
        checkOutImage: "/uploads/employees/123/checkout_2025-10-06_17-00-00.jpg",
        status: "Present",
        hours: 8.0
      }
    ]
  }
}
```

## 🧪 **Testing**

### **Verify Camera Feature**
```bash
# Test database storage
cd Backend
node verify-database-images.js

# Test Docker deployment
docker-compose up --build -d
docker exec -it container_name find /app/uploads -name "*.jpg"
```

### **Test Image Upload**
1. Employee checks in with camera
2. Verify image saved to `/uploads/employees/{id}/`
3. Check MongoDB for image paths
4. View in admin panel "Attendance Images"

## 📈 **Performance**

- **Image Size Limit**: 5MB per photo
- **Format**: JPG with 95% quality
- **Storage**: Employee-specific folders
- **Database**: Optimized queries with image paths
- **Docker**: Persistent volumes for scalability

## 🔒 **Security**

- **File Validation**: Only image files accepted
- **Size Limits**: 5MB maximum per upload
- **Path Sanitization**: Secure file naming
- **Admin Only**: Photo viewing restricted to admins
- **Authentication**: JWT-based access control

## 🌟 **Key Benefits**

1. **Visual Verification** - Photos prove attendance
2. **Fraud Prevention** - Camera prevents buddy punching
3. **Audit Trail** - Complete photo history
4. **Easy Management** - Admin-friendly photo viewer
5. **Scalable Storage** - Docker volumes for growth
6. **Production Ready** - Multiple deployment options

## 📞 **Support**

### **Troubleshooting**
- Check `CAMERA_FEATURE_COMPLETE.md` for full documentation
- Run `Backend/verify-database-images.js` to test database
- Check Docker logs: `docker-compose logs backend`
- Verify file permissions in uploads directory

### **Common Issues**
1. **Camera not opening** - Check browser permissions
2. **Images not saving** - Verify multer configuration
3. **Admin panel empty** - Check API endpoint returns
4. **Docker issues** - Ensure volumes are mounted

## 📝 **License**

This project is open source and available under the [MIT License](LICENSE).

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 🎉 **Success!**

Your attendance portal now includes:
- ✅ **Camera capture** for check-in/check-out
- ✅ **Image storage** in JPG format  
- ✅ **Database integration** with MongoDB
- ✅ **Admin photo viewer** with table display
- ✅ **Docker support** with persistent storage
- ✅ **Production deployment** ready

**Ready to deploy and use! 🚀📸**

---

**Repository**: [https://github.com/Venkyudemy/attendanceportal-c.git](https://github.com/Venkyudemy/attendanceportal-c.git)

**Live Demo**: Deploy using Docker for immediate testing!