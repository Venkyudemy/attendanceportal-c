# 📸 Attendance Images Troubleshooting Guide

## Issue: Images Not Showing

If your Attendance Images page shows "No attendance images found", follow these steps:

---

## ✅ **Step 1: Test Employee Check-In**

### **Do This Right Now:**

1. **Login as Employee:**
   - Go to http://localhost:3000
   - Login with employee credentials (NOT admin)
   - Example: `sai@gmail.com` / password

2. **Check In with Photo:**
   - Click "Check In" button
   - Camera opens
   - Capture photo
   - Click "Confirm"
   - ✅ You should see "Check-in successful"

3. **Check Out with Photo:**
   - Click "Check Out" button
   - Camera opens
   - Capture photo
   - Click "Confirm"
   - ✅ You should see "Check-out successful"

---

## ✅ **Step 2: Check Debug Info**

1. **Logout from employee**
2. **Login as Admin:**
   - Email: `admin@techcorp.com`
   - Password: `password123`

3. **Go to Attendance Images:**
   - Click "📸 Attendance Images" in sidebar
   - Look at the **yellow debug box** at the top

4. **Check the Debug Info:**
   ```
   🔍 Debug Info:
   Selected Date: 2024-10-06
   Total Employees: 5
   Employees with Images: 1  ← Should be 1 or more!
   ```

5. **Expand "Sample Employee Data":**
   - Click to see what's in the database
   - Check if `todayCheckInImage` and `todayCheckOutImage` are present

---

## ✅ **Step 3: Check Browser Console**

1. **Open Browser Console:**
   - Press `F12`
   - Go to "Console" tab

2. **Look for These Messages:**
   ```
   📸 Fetching attendance images for date: 2024-10-06
   📊 Received employees data: 5
   Employee sai: {...}
   ✅ Formatted data with images: 1
   ```

3. **Check Employee Details:**
   - Look for each employee log
   - Check if `todayImages.checkIn` has a value
   - Should look like: `/uploads/employees/67234.../checkin_2024-10-06_09-15-30.jpg`

---

## ✅ **Step 4: Verify File System**

1. **Check Backend Folder:**
   ```
   Backend/uploads/employees/
   ```

2. **You Should See:**
   ```
   employees/
   ├── {employeeId}/
   │   ├── checkin_2024-10-06_09-15-30.jpg  ← File exists?
   │   └── checkout_2024-10-06_17-30-45.jpg ← File exists?
   ```

3. **If Folders Don't Exist:**
   - Restart backend server
   - Try check-in/check-out again

---

## ✅ **Step 5: Check Date Format**

### **Common Issue: Date Mismatch**

The date format must match! Check console logs for:

```javascript
// Should match:
selectedDate: "2024-10-06"
today: "2024-10-06"
todayRecord.date: "2024-10-06"  ← Must be the same!
```

If dates don't match, images won't show!

---

## 🔍 **Quick Checks:**

### **1. Is Backend Running?**
```powershell
# Check if backend is running on port 5000
# You should see console output
```

### **2. Is Frontend Running?**
```powershell
# Check if frontend is running on port 3000
# Should auto-reload after changes
```

### **3. Test Image Path:**
Open browser and try:
```
http://localhost:5000/uploads/employees/{employeeId}/checkin_2024-10-06_09-15-30.jpg
```

If this shows an image, backend is serving files correctly!

---

## 🐛 **Common Problems & Solutions:**

### **Problem 1: "No attendance images found"**

**Solution:**
- Employee needs to check in/out **TODAY**
- Select TODAY's date in the date picker
- Images only show for dates when photos were captured

### **Problem 2: Debug shows "0 Employees with Images"**

**Solution:**
```javascript
// Check console for:
todayImages: {
  checkIn: null,  ← Should have a value!
  checkOut: null  ← Should have a value!
}
```

If null, images weren't saved. Try checking in again.

### **Problem 3: Folder exists but images don't show**

**Solution:**
- Check database has image paths
- Restart backend
- Clear browser cache (Ctrl+Shift+Delete)

### **Problem 4: Date picker shows future dates**

**Solution:**
- Max date is set to TODAY
- Can only select today or past dates
- Check calendar limits

---

## 🧪 **Test Scenario:**

### **Complete Test Flow:**

```
Step 1: Fresh Check-In
- Login as employee (sai@gmail.com)
- Click "Check In"
- Capture photo with camera
- Confirm
- See success message ✅

Step 2: Check Backend Logs
- Backend console should show:
  📸 Image uploaded: /uploads/employees/XXX/checkin_2024-10-06_XX-XX-XX.jpg
  ✅ Check-in with image saved successfully

Step 3: Check File Created
- Navigate to: Backend/uploads/employees/{employeeId}/
- See JPG file ✅

Step 4: View in Admin Panel
- Logout
- Login as admin
- Go to "📸 Attendance Images"
- See employee in table with photo ✅

Step 5: Verify Photo
- Click photo
- Opens full-size in new tab ✅
```

---

## 📊 **Expected Debug Output:**

### **When Working Correctly:**

```
🔍 Debug Info:
Selected Date: 2024-10-06 (formatted: 2024-10-06)
Total Employees: 5
Employees with Images: 1

Sample Employee Data:
[
  {
    "name": "sai",
    "todayDate": "2024-10-06",
    "todayCheckInImage": "/uploads/employees/67234.../checkin_2024-10-06_09-15-30.jpg",
    "todayCheckOutImage": "/uploads/employees/67234.../checkout_2024-10-06_17-30-45.jpg",
    "recordsCount": 1
  }
]
```

### **When NOT Working:**

```
🔍 Debug Info:
Selected Date: 2024-10-06 (formatted: 2024-10-06)
Total Employees: 5
Employees with Images: 0  ← Problem!

Sample Employee Data:
[
  {
    "name": "sai",
    "todayDate": "2024-10-05",  ← Wrong date!
    "todayCheckInImage": null,  ← No image!
    "todayCheckOutImage": null,
    "recordsCount": 0
  }
]
```

---

## 🔄 **Reset and Try Again:**

If nothing works:

1. **Restart Backend:**
   ```powershell
   cd Backend
   # Press Ctrl+C to stop
   npm start
   ```

2. **Clear Browser:**
   - Press Ctrl+Shift+Delete
   - Clear cache
   - Refresh page

3. **Fresh Check-In:**
   - Login as employee
   - Check in with photo
   - Check out with photo

4. **Check Admin Panel:**
   - Login as admin
   - Go to Attendance Images
   - Should see photos!

---

## 📞 **Still Not Working?**

Check these in console (F12):

1. **Network Tab:**
   - Look for `/api/employee/attendance` request
   - Status should be 200
   - Response should have employee data

2. **Console Logs:**
   - Look for "📸 Fetching attendance images"
   - Check employee data logs
   - Share screenshot if needed

3. **Backend Console:**
   - Look for "📸 Image uploaded"
   - Look for "✅ Check-in with image saved"
   - Check for errors

---

**Most likely issue:** Employee needs to check in/out TODAY with photos, then images will appear!

**Try this:** Login as employee → Check In → Capture Photo → Then check admin panel!


