# 🚀 SIMPLE START GUIDE

## ⚠️ **Connection Error Fix:**

The "Unable to reach the server" error means the **backend is not running**!

---

## ✅ **EASIEST WAY TO START:**

### **Option 1: Use the Start Script (RECOMMENDED)**

1. **Double-click this file:**
   ```
   START_SERVERS.bat
   ```

2. **Two windows will open:**
   - Backend Server window
   - Frontend Server window

3. **Wait until you see:**
   - Backend: "✅ Server running on http://0.0.0.0:5000"
   - Frontend: "Compiled successfully!"

4. **Go to:** http://localhost:3000

5. **Login:**
   - Admin: admin@techcorp.com / password123
   - Employee: sai@gmail.com / password

---

### **Option 2: Manual Start (if Option 1 doesn't work)**

**Terminal 1 - Backend:**
```powershell
cd C:\Users\user\Desktop\attendence main -2\attendanceportal-main1-main\attendanceportal-main1-main\attendanceportal-main\Backend

npm start
```

**Wait for:**
```
✅ Connected to MongoDB successfully
✅ Server running on http://0.0.0.0:5000
```

**Terminal 2 - Frontend (open NEW terminal):**
```powershell
cd C:\Users\user\Desktop\attendence main -2\attendanceportal-main1-main\attendanceportal-main1-main\attendanceportal-main\Frontend

npm start
```

**Wait for:**
```
Compiled successfully!
webpack compiled with 0 warnings
```

---

## 🔍 **Verify Backend is Running:**

**Test in browser:**
```
http://localhost:5000
```

**Should show:**
```json
{
  "message": "Attendance Portal Backend is running",
  "status": "OK"
}
```

**If you see this → Backend is working!**

---

## 📸 **After Servers Start:**

1. **Go to:** http://localhost:3000
2. **Login as admin:**
   - Email: admin@techcorp.com
   - Password: password123
3. **Click:** "📸 Attendance Images"
4. **You should see:** Employee sai with both photos!

---

## ⚠️ **Common Issues:**

### **MongoDB Not Running:**

Backend console shows:
```
❌ MongoDB connection error
```

**Fix:**
```powershell
docker run -d -p 27017:27017 --name mongodb mongo:6
```

OR if MongoDB installed locally:
```powershell
mongod
```

### **Port Already in Use:**

```
Error: listen EADDRINUSE :::5000
```

**Fix:**
```powershell
# Kill process on port 5000
Stop-Process -Name node -Force
```

Then restart: `npm start`

---

## ✅ **Quick Checklist:**

- [ ] Backend running (check http://localhost:5000)
- [ ] Frontend running (check http://localhost:3000)
- [ ] MongoDB running
- [ ] No error messages in consoles
- [ ] Can login successfully
- [ ] Can navigate to Attendance Images
- [ ] Can see photos in table

---

## 🎯 **Your Images ARE Ready:**

```
✅ Check-in image: checkin_2025-10-06_16-14-36.jpg
✅ Check-out image: checkin_2025-10-06_18-08-00.jpg
✅ Saved in database
✅ Files on disk
```

**Just need to start the servers!**

---

**Double-click `START_SERVERS.bat` now!** 🚀
