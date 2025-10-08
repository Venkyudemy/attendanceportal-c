# 📸 Image Storage & Admin Panel Guide

## 🎯 **Your Images Are Stored Here:**

### **Backend Container Storage:**
```
/app/uploads/employees/[EMPLOYEE_ID]/
├── checkin_2025-01-08_10-30-45.jpg
├── checkout_2025-01-08_17-30-15.jpg
└── checkin_2025-01-09_09-15-30.jpg
```

### **Database Storage Paths:**
```javascript
// In MongoDB, employee documents contain:
{
  "attendance": {
    "today": {
      "checkInImage": "/uploads/employees/[EMPLOYEE_ID]/checkin_2025-01-08_10-30-45.jpg",
      "checkOutImage": "/uploads/employees/[EMPLOYEE_ID]/checkout_2025-01-08_17-30-15.jpg"
    },
    "records": [
      {
        "date": "2025-01-08",
        "checkInImage": "/uploads/employees/[EMPLOYEE_ID]/checkin_2025-01-08_10-30-45.jpg",
        "checkOutImage": "/uploads/employees/[EMPLOYEE_ID]/checkout_2025-01-08_17-30-15.jpg"
      }
    ]
  }
}
```

### **Web Access URLs:**
```
https://hzzeinfo.xyz/uploads/employees/[EMPLOYEE_ID]/checkin_2025-01-08_10-30-45.jpg
https://hzzeinfo.xyz/uploads/employees/[EMPLOYEE_ID]/checkout_2025-01-08_17-30-15.jpg
```

## 🔍 **How to Check Image Storage:**

### **1. Check Backend Container:**
```bash
# List all employee folders
docker-compose -f docker-compose.prod.yml exec backend ls -la /app/uploads/employees/

# Find all captured images
docker-compose -f docker-compose.prod.yml exec backend find /app/uploads -type f -name "*.jpg"

# Check specific employee folder
docker-compose -f docker-compose.prod.yml exec backend ls -la /app/uploads/employees/[EMPLOYEE_ID]/
```

### **2. Check Database:**
```bash
# Run the employee check script
docker-compose -f docker-compose.prod.yml exec backend node check-employee.js

# Check database directly
docker-compose -f docker-compose.prod.yml exec backend node -e "
const mongoose = require('mongoose');
const Employee = require('./models/Employee');

mongoose.connect('mongodb://mongo:27017/attendanceportal')
  .then(async () => {
    const employees = await Employee.find({});
    employees.forEach(emp => {
      if (emp.attendance?.today?.checkInImage || emp.attendance?.today?.checkOutImage) {
        console.log('📸', emp.name, ':');
        console.log('  Check-in:', emp.attendance.today.checkInImage || 'None');
        console.log('  Check-out:', emp.attendance.today.checkOutImage || 'None');
      }
    });
    process.exit(0);
  });
"
```

### **3. Test Image Access:**
```bash
# Test Nginx proxy
curl -k -I https://localhost/uploads/

# Test specific image (replace with actual path)
curl -k -I https://localhost/uploads/employees/[EMPLOYEE_ID]/checkin_2025-01-08_10-30-45.jpg
```

## 📊 **Admin Panel Access:**

### **URL:**
```
https://hzzeinfo.xyz/attendance-images
```

### **Features:**
- ✅ View all employee attendance images
- ✅ Filter by date
- ✅ See check-in and check-out photos side by side
- ✅ Click images to view full size
- ✅ Debug panel showing raw database data

### **Navigation:**
1. Login as admin at https://hzzeinfo.xyz
2. Click "Attendance Images" in sidebar (📸 icon)
3. Select date to filter images
4. View captured photos in table format

## 🛠️ **Troubleshooting:**

### **Images Not Showing in Admin Panel:**

1. **Check if images exist:**
   ```bash
   check-image-storage.bat
   ```

2. **Rebuild frontend with fixes:**
   ```bash
   fix-admin-images.bat
   ```

3. **Check browser console for errors:**
   - Open Developer Tools (F12)
   - Look for failed image loads
   - Check Network tab for 404 errors

4. **Verify image URLs:**
   - Images should load from `/uploads/...`
   - NOT from `http://localhost:5000/uploads/...`

### **Common Issues:**

| Issue | Cause | Solution |
|-------|-------|----------|
| Images not displaying | Hardcoded localhost URLs | Run `fix-admin-images.bat` |
| 404 errors on images | Nginx proxy not working | Check `/uploads/` location in nginx config |
| Database has no images | Employee check-in failed | Check backend logs for upload errors |
| Images save but don't show | Wrong API URL in admin panel | Rebuild frontend with correct API URLs |

## 🎯 **Quick Fix Commands:**

### **Check Everything:**
```bash
check-image-storage.bat
```

### **Fix Admin Images:**
```bash
fix-admin-images.bat
```

### **Complete Rebuild:**
```bash
run-production.bat
```

## 📋 **Expected File Structure:**

```
Backend Container:
/app/uploads/employees/
├── 507f1f77bcf86cd799439011/  # Employee 1
│   ├── checkin_2025-01-08_09-15-30.jpg
│   └── checkout_2025-01-08_17-30-15.jpg
├── 507f1f77bcf86cd799439012/  # Employee 2
│   ├── checkin_2025-01-08_09-20-45.jpg
│   └── checkout_2025-01-08_18-15-20.jpg
└── 507f1f77bcf86cd799439013/  # Employee 3
    └── checkin_2025-01-08_09-25-10.jpg

Database Paths:
- checkInImage: "/uploads/employees/507f1f77bcf86cd799439011/checkin_2025-01-08_09-15-30.jpg"
- checkOutImage: "/uploads/employees/507f1f77bcf86cd799439011/checkout_2025-01-08_17-30-15.jpg"

Web Access:
- https://hzzeinfo.xyz/uploads/employees/507f1f77bcf86cd799439011/checkin_2025-01-08_09-15-30.jpg
- https://hzzeinfo.xyz/uploads/employees/507f1f77bcf86cd799439011/checkout_2025-01-08_17-30-15.jpg
```

---

## 🎉 **Your Images Are Working!**

After running the fixes:
- ✅ Images are stored in `/app/uploads/employees/[EMPLOYEE_ID]/`
- ✅ Database contains correct image paths
- ✅ Admin panel displays images properly
- ✅ Images are accessible via HTTPS URLs

**Check your admin panel at: https://hzzeinfo.xyz/attendance-images** 📸
