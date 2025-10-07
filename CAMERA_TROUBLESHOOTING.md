# 📸 Camera Troubleshooting Guide

## Issue: Camera Shows Black Screen

If you see a black screen when the camera modal opens, follow these steps:

### ✅ **Step 1: Check Browser Permissions**

#### **Chrome/Edge:**
1. Look for the camera icon in the address bar
2. Click it and select "Always allow camera access"
3. Refresh the page (F5)
4. Try check-in again

**OR manually:**
1. Click the 🔒 padlock/info icon in address bar
2. Click "Site settings"
3. Find "Camera" and set to "Allow"
4. Refresh the page

#### **Firefox:**
1. Look for camera icon in address bar
2. Click and select "Allow"
3. Check "Remember this decision"
4. Refresh the page

#### **Safari:**
1. Safari → Preferences → Websites → Camera
2. Find localhost and set to "Allow"
3. Refresh the page

### ✅ **Step 2: Check if Camera is Working**

1. **Test your camera:**
   - Windows: Open Camera app
   - Mac: Open Photo Booth
   - Or visit: https://www.webcamtests.com/

2. **Close other apps using camera:**
   - Close Zoom, Teams, Skype, etc.
   - Close other browser tabs with camera access
   - Restart browser

### ✅ **Step 3: Browser Console Check**

1. **Open Developer Console:**
   - Press `F12` or `Ctrl+Shift+I` (Windows)
   - Press `Cmd+Option+I` (Mac)

2. **Look for errors:**
   - Check Console tab for error messages
   - Look for camera-related errors

3. **Common error messages:**

   **"NotAllowedError"**
   - Solution: Grant camera permissions (see Step 1)

   **"NotFoundError"**
   - Solution: No camera detected, check if camera is plugged in

   **"NotReadableError"**
   - Solution: Camera in use by another app, close other apps

### ✅ **Step 4: Use HTTPS or Localhost**

Browsers require HTTPS or localhost for camera access:

- ✅ `http://localhost:3000` - Works
- ✅ `https://yourdomain.com` - Works
- ❌ `http://192.168.x.x` - May not work
- ❌ `http://yourdomain.com` - May not work

**If using IP address:**
- Use Chrome flag: `chrome://flags/#unsafely-treat-insecure-origin-as-secure`
- Or set up HTTPS

### ✅ **Step 5: Clear Browser Cache**

1. **Chrome/Edge:**
   - Press `Ctrl+Shift+Delete`
   - Select "Cached images and files"
   - Click "Clear data"
   - Restart browser

2. **Firefox:**
   - Press `Ctrl+Shift+Delete`
   - Select "Cache"
   - Click "Clear Now"
   - Restart browser

### ✅ **Step 6: Check Error Messages in Modal**

The improved camera component now shows specific errors:

- **"Please grant camera permissions"** → Follow Step 1
- **"No camera found"** → Check hardware connection
- **"Camera is already in use"** → Close other apps
- **"Browser does not support camera"** → Update browser
- **"Starting camera..."** → Wait a few seconds

### ✅ **Step 7: Try Different Browser**

Test in order:
1. ✅ Chrome (recommended)
2. ✅ Edge (recommended)
3. ✅ Firefox
4. ❌ Internet Explorer (not supported)

### ✅ **Step 8: Check System Settings**

#### **Windows 10/11:**
1. Settings → Privacy → Camera
2. Enable "Allow apps to access your camera"
3. Enable "Allow desktop apps to access your camera"
4. Restart browser

#### **Mac:**
1. System Preferences → Security & Privacy → Camera
2. Check the box next to your browser
3. Restart browser

### ✅ **Step 9: Update Browser**

Make sure you're using the latest browser version:
- Chrome: Settings → About Chrome
- Firefox: Help → About Firefox
- Edge: Settings → About Microsoft Edge

### ✅ **Step 10: Restart Everything**

1. Close all browser windows
2. Restart browser
3. Clear camera permissions: chrome://settings/content/camera
4. Try again

## 🔍 **Advanced Debugging**

### Check Camera Access in Console:

Open browser console (F12) and run:

```javascript
navigator.mediaDevices.getUserMedia({ video: true })
  .then(stream => {
    console.log('✅ Camera works!', stream);
    stream.getTracks().forEach(track => track.stop());
  })
  .catch(err => {
    console.error('❌ Camera error:', err.name, err.message);
  });
```

### Check Available Cameras:

```javascript
navigator.mediaDevices.enumerateDevices()
  .then(devices => {
    const cameras = devices.filter(d => d.kind === 'videoinput');
    console.log('📹 Available cameras:', cameras);
  });
```

## 🚀 **Quick Fixes Summary**

| Issue | Solution |
|-------|----------|
| Black screen | Grant camera permissions |
| "Permission denied" | Check browser & system settings |
| "No camera found" | Check hardware connection |
| "Already in use" | Close other apps |
| Works in app but not browser | System permissions blocked |
| Not working in Chrome | Try incognito mode first |

## 📱 **Mobile Issues**

### iOS Safari:
- Must be HTTPS (not http)
- Grant permissions when prompted
- Settings → Safari → Camera → Allow

### Android Chrome:
- Grant permissions when prompted
- Settings → Site Settings → Camera → Allow
- Check Android system camera permissions

## ⚠️ **Common Mistakes**

1. ❌ Denying permission prompt
   - ✅ Must click "Allow" when browser asks

2. ❌ Using HTTP on non-localhost
   - ✅ Use HTTPS or localhost

3. ❌ Camera blocked by system
   - ✅ Check system privacy settings

4. ❌ Old browser version
   - ✅ Update to latest version

5. ❌ Camera in use by another app
   - ✅ Close all apps using camera

## 🛠️ **Still Not Working?**

### Collect Debug Info:

1. **Browser:** (Chrome/Firefox/Edge/Safari)
2. **Version:** (Help → About)
3. **OS:** (Windows/Mac/Linux)
4. **Error in console:** (F12 → Console tab)
5. **Camera test result:** (webcamtests.com)

### Error Message Meanings:

```
🎥 Requesting camera access...
✅ Camera access granted      → Success!
❌ Error accessing camera     → Check error message below
```

## 📞 **Need Help?**

If camera still doesn't work after following all steps:

1. ✅ Try in incognito/private mode
2. ✅ Try different browser
3. ✅ Test camera in other apps
4. ✅ Check antivirus/firewall settings
5. ✅ Restart computer

## ✨ **Success Checklist**

- [ ] Camera permissions granted in browser
- [ ] Camera permissions granted in system settings
- [ ] No other apps using camera
- [ ] Using HTTPS or localhost
- [ ] Browser is up to date
- [ ] Camera works in other apps
- [ ] Developer console shows no errors

---

**Once camera is working, you should see:**
1. Loading spinner → "Starting camera..."
2. Your live camera feed (mirrored)
3. Large "📷 Capture" button

**Made with ❤️ for seamless attendance tracking**

