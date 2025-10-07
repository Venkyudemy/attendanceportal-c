# 🐳 Docker Compose Updated for Camera Feature

## ✅ **Updated Files:**

### **1. `docker-compose.yml` (Main Development)**
### **2. `docker-compose.prod.yml` (Production)**
### **3. `Backend/Dockerfile` (Container Image)**

---

## 🔧 **Changes Made:**

### **📁 Volume Mounts Added:**
```yaml
volumes:
  - ./Backend/scripts:/app/scripts:ro
  - uploads_data:/app/uploads  # ← NEW: For camera images
```

### **🌍 Environment Variables Added:**
```yaml
environment:
  # ... existing variables ...
  - MAX_FILE_SIZE=5242880      # ← NEW: 5MB limit for images
  - UPLOAD_PATH=/app/uploads   # ← NEW: Upload directory path
```

### **💾 Docker Volumes Added:**
```yaml
volumes:
  mongo_data:
    driver: local
  uploads_data:                # ← NEW: Persistent image storage
    driver: local
```

### **📂 Directory Creation in Dockerfile:**
```dockerfile
# Create directories for uploads and scripts
RUN mkdir -p scripts uploads/employees

# Set proper permissions for uploads directory
RUN chmod 755 uploads uploads/employees
```

---

## 🎯 **What This Enables:**

### **✅ Camera Image Storage:**
- Images saved to persistent Docker volume
- Survives container restarts
- Employee-specific folders created automatically
- Proper file permissions set

### **✅ File Upload Limits:**
- 5MB maximum file size
- Prevents oversized uploads
- Environment-configurable

### **✅ Production Ready:**
- Both development and production configs updated
- Persistent storage across deployments
- Proper directory structure

---

## 📊 **Docker Volume Structure:**

```
uploads_data (Docker Volume)
└── employees/
    ├── employee_id_1/
    │   ├── checkin_2025-10-06_09-30-15.jpg
    │   ├── checkout_2025-10-06_17-45-22.jpg
    │   └── ...
    ├── employee_id_2/
    │   ├── checkin_2025-10-06_09-15-30.jpg
    │   └── ...
    └── ...
```

---

## 🚀 **Deployment Commands:**

### **Development:**
```bash
docker-compose up -d
```

### **Production:**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### **Rebuild with Camera Updates:**
```bash
# Stop containers
docker-compose down

# Rebuild with new changes
docker-compose up --build -d

# Or for production
docker-compose -f docker-compose.prod.yml up --build -d
```

---

## 🔍 **Verification:**

### **Check Volume Mount:**
```bash
docker exec -it attendanceportal-main1-main_backend_1 ls -la /app/uploads/
```

### **Check Image Storage:**
```bash
docker exec -it attendanceportal-main1-main_backend_1 find /app/uploads -name "*.jpg" -type f
```

### **Test Image Upload:**
1. Employee checks in with camera
2. Image saved to `/app/uploads/employees/{employeeId}/`
3. Path stored in MongoDB
4. Visible in admin panel

---

## 📋 **Updated Configuration Summary:**

| Component | Change | Purpose |
|-----------|--------|---------|
| **Backend Volume** | Added `uploads_data:/app/uploads` | Persistent image storage |
| **Environment** | Added `MAX_FILE_SIZE=5242880` | 5MB upload limit |
| **Environment** | Added `UPLOAD_PATH=/app/uploads` | Upload directory path |
| **Dockerfile** | Added `mkdir -p uploads/employees` | Create upload directories |
| **Dockerfile** | Added `chmod 755 uploads` | Set proper permissions |
| **Volume Definition** | Added `uploads_data` volume | Persistent storage |

---

## ✅ **Camera Feature Docker Integration:**

### **Complete Flow:**
```
1. Employee → Check In → Camera Opens
2. Capture Photo → Upload to Backend
3. Backend → Save to /app/uploads/employees/{id}/
4. Backend → Save path to MongoDB
5. Docker Volume → Persistent storage
6. Admin Panel → Display images
7. Container Restart → Images preserved ✅
```

### **Benefits:**
- ✅ **Persistent Storage**: Images survive container restarts
- ✅ **Scalable**: Multiple containers can share volume
- ✅ **Secure**: Proper file permissions
- ✅ **Organized**: Employee-specific folders
- ✅ **Production Ready**: Both dev and prod configs

---

## 🎉 **Docker Update Complete!**

**Your attendance portal now has:**
- ✅ Docker support for camera images
- ✅ Persistent image storage
- ✅ Proper file permissions
- ✅ Production-ready configuration
- ✅ 5MB upload limits
- ✅ Employee folder organization

**Ready for Docker deployment with camera feature! 🐳📸**
