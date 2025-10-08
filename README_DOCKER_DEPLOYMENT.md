# 🐳 Docker Deployment Guide - Attendance Portal

## 📋 **Quick Start Commands**

### **Development Environment:**
```cmd
run-development.bat
```
- Frontend: http://localhost:3000
- Backend: http://localhost:5000
- MongoDB: localhost:27017

### **Production Environment:**
```cmd
run-production.bat
```
- Frontend: https://hzzeinfo.xyz
- Backend: http://localhost:5000
- MongoDB: localhost:27017

### **Quick Fix for Employee Check-In Issue:**
```cmd
quick-fix-employee.bat
```

## 🔧 **Docker Compose Files**

### **docker-compose.yml (Development)**
- **SSL:** Disabled
- **Ports:** 3000:80 (frontend), 5000:5000 (backend), 27017:27017 (mongo)
- **Environment:** Development mode
- **CORS:** http://localhost:3000
- **Features:** Camera capture, image upload, admin panel

### **docker-compose.prod.yml (Production)**
- **SSL:** Enabled (requires certificates)
- **Ports:** 80:80, 443:443 (frontend), 5000:5000 (backend), 27017:27017 (mongo)
- **Environment:** Production mode
- **CORS:** https://hzzeinfo.xyz
- **Features:** HTTPS, camera capture, image upload, admin panel

## 📁 **Updated Docker Compose Features**

### **Frontend Service:**
```yaml
frontend:
  build:
    context: ./Frontend
    dockerfile: Dockerfile
    args:
      ENABLE_SSL: "true"  # or "false" for development
  ports:
    - "80:80"
    - "443:443"  # Only in production
  environment:
    - REACT_APP_API_URL=/api  # Fixed API URL
  volumes:
    - ./certs:/etc/nginx/certs:ro  # SSL certificates
```

### **Backend Service:**
```yaml
backend:
  build:
    context: ./Backend
    dockerfile: Dockerfile
  environment:
    - NODE_ENV=production
    - FRONTEND_ORIGIN=https://hzzeinfo.xyz  # CORS configuration
    - MAX_FILE_SIZE=5242880  # 5MB for image uploads
    - UPLOAD_PATH=/app/uploads
  volumes:
    - uploads_data:/app/uploads  # Persistent image storage
  command: >
    sh -c "
      echo '🚀 Starting production deployment...' &&
      sleep 15 &&
      echo '🔍 Checking admin user...' &&
      # Admin initialization script
      echo '🔍 Verifying employee database...' &&
      node check-employee.js &&
      echo '🚀 Starting backend server...' &&
      npm start
    "
```

### **MongoDB Service:**
```yaml
mongo:
  image: mongo:6
  volumes:
    - mongo_data:/data/db
    - ./Backend/scripts:/docker-entrypoint-initdb.d:ro
  command: mongod --bind_ip_all
```

## 🎯 **Key Improvements Made**

### **1. API URL Configuration**
- ✅ Frontend now uses `/api` instead of `http://localhost:5000/api`
- ✅ Runtime environment variables from `window.env`
- ✅ Proper API URL resolution in production

### **2. Camera Capture Support**
- ✅ HTTPS enabled for camera access
- ✅ Large file upload support (5MB)
- ✅ Proper image storage in `/uploads/employees/`
- ✅ Nginx proxy for serving uploaded images

### **3. Employee Database Management**
- ✅ Automatic employee verification on startup
- ✅ Employee creation if missing
- ✅ Database initialization scripts

### **4. SSL/HTTPS Support**
- ✅ SSL certificates mounting
- ✅ HTTP to HTTPS redirect
- ✅ Secure camera access

## 🚀 **Deployment Steps**

### **For Development:**
1. Run `run-development.bat`
2. Open http://localhost:3000
3. Test camera capture functionality

### **For Production:**
1. Ensure SSL certificates are in `./certs/` directory
2. Run `run-production.bat`
3. Open https://hzzeinfo.xyz
4. Test camera capture functionality

### **For Quick Fix:**
1. Run `quick-fix-employee.bat`
2. Test employee check-in immediately

## 🔍 **Troubleshooting**

### **Employee Check-In Issues:**
```cmd
# Check employee database
docker-compose -f docker-compose.prod.yml exec backend node check-employee.js

# Check API connectivity
curl -k https://localhost/api/health

# Check logs
docker-compose -f docker-compose.prod.yml logs backend -f
```

### **Camera Not Working:**
1. Ensure HTTPS is enabled (required for camera access)
2. Check browser console for API URL errors
3. Verify SSL certificates are valid

### **Images Not Saving:**
1. Check uploads directory permissions
2. Verify Nginx proxy configuration
3. Check backend logs for upload errors

## 📊 **Service URLs**

### **Development:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000/api
- MongoDB: mongodb://localhost:27017/attendanceportal

### **Production:**
- Frontend: https://hzzeinfo.xyz
- Backend API: https://hzzeinfo.xyz/api (proxied)
- MongoDB: mongodb://mongo:27017/attendanceportal (internal)

## 🎉 **Expected Results**

After deployment:
- ✅ Employee login works
- ✅ Camera opens for check-in/check-out
- ✅ Photos are captured and saved
- ✅ Images appear in admin panel
- ✅ No "Employee not found" errors
- ✅ HTTPS works properly
- ✅ All API endpoints function correctly

**Your attendance portal with camera capture is now ready for production! 🚀**
